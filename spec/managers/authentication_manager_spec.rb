describe AuthenticationManager do
  let(:email) { 'szinin-non-admin@gmail.com' }
  let(:password) { 'qwerty' }
  let(:password_confirmation) { 'qwerty' }
  let(:first_name) { 'sergei' }
  let(:last_name) { 'zinin' }
  let(:api_token) { 'invalid' }
  let(:tos_accepted) { true }

  subject(:manager) { described_class.new(email: email,
                                          password: password,
                                          password_confirmation: password_confirmation,
                                          first_name: first_name,
                                          last_name: last_name,
                                          tos_accepted: tos_accepted,
                                          api_token: api_token) }

  describe '#register' do
    subject(:register) { manager.register }

    it { is_expected.to be_a User }
    it { is_expected.to be_valid }
    it { is_expected.not_to be_a_new_record }
    its(:email) { is_expected.to eq(email) }
    its(:password_hash) { is_expected.not_to be_blank }
    its(:full_name) { is_expected.to eq('Sergei Zinin') }
    its(:auth_token) { is_expected.not_to be_blank }

    specify { expect { register }.to change(User, :count).by(1) }
    specify { expect { register }.to create_event(:registered) }

    context do
      let!(:tos_version) { create(:tos_version, :published) }

      it { expect { register }.to create_record(TosAcceptance).matching(tos_version: tos_version) }
      it { expect { register }.to create_record(User).matching(tos_accepted: true) }
    end

    context 'already registered user' do
      before { manager.register }

      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }

      context 'in another session' do
        let(:another_manager) { described_class.new(email: email,
                                                password: password,
                                                password_confirmation: password_confirmation,
                                                first_name: first_name,
                                                last_name: last_name,
                                                api_token: api_token) }
        specify { expect { another_manager.register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) } }
      end
    end

    context 'name contains numbers' do
      context 'first name' do
        let(:first_name) { 'sergei1' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:first_name) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end

      context 'last name' do
        let(:last_name) { 'sergei1' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:last_name) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end
    end

    context 'invalid email' do
      context '"whatever"' do
        let(:email) { 'whatever' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:default)) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end

      context '"what ever@gmail.com"' do
        let(:email) { 'what ever@gmail.com' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:default)) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end
    end

    context 'empty email' do
      let(:email) { '' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:empty)) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'forbidden email' do
      let(:email) { "tester@#{APP_CONFIG['forbidden_email_domains'].sample}" }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:invalid)) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'password confirmation does not match' do
      let(:password_confirmation) { 'qwertyui' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:password_confirmation) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'short password' do
      let(:password) { 'qwer' }
      let(:password_confirmation) { 'qwer' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:password) } }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).not_to have_key(:password_confirmation) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'tos not accepted' do
      let(:tos_accepted) { false }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:tos_accepted) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end
  end

  describe '#authenticate' do
    subject(:authenticate) { manager.authenticate }

    context 'registered user' do
      before { manager.register }

      it { is_expected.to be_a User }
      it { is_expected.not_to be_new_record }
      its(:email) { is_expected.to eq email }

      specify { expect { authenticate }.to create_event(:logged_in) }
    end

    context 'not registered user' do
      specify { expect { authenticate }.to raise_error(ManagerError) }
      specify { expect { authenticate rescue nil }.not_to create_event(:logged_in) }
    end

    context 'having wrong password' do
      before do
        manager.register
      end

      specify do
        expect { described_class.new(email: email, password: 'wrong_password').authenticate }.to raise_error(AuthenticationError)
      end

      specify do
        expect { described_class.new(email: email, password: 'wrong_password').authenticate rescue nil }.not_to create_event(:logged_in)
      end
    end

    context 'duplicate email' do
      context 'duplicate is active' do
        let!(:user) { manager.register }
        let!(:activated_duplicate) do
          expect(user).not_to be_activated
          create(:user, email: 'just@any.ru', activated: false, password_hash: user.password_hash).tap do |duplicate|
            UserProfileManager.new(duplicate).update_general_information(full_name: 'test', company_name: nil, email: user.email)
            UserManager.new(duplicate).activate
          end
        end

        specify do
          expect(user).not_to be_activated
          expect(activated_duplicate).to be_activated
        end

        specify do
          expect { authenticate }.to create_event(:logged_in)
        end

        specify do
          expect { authenticate }.to create_event(:logged_in).with_user(activated_duplicate)
        end
      end

      context 'original user is active' do
        let!(:active_user) do
          manager.register.tap do |user|
            UserManager.new(user).activate
          end
        end

        let(:duplicate) do
          create(:user, email: 'just@any.ru', activated: false)
        end

        def change_email
          UserProfileManager.new(duplicate).update_general_information(full_name: 'test', company_name: nil, email: active_user.email)
        end

        specify do
          expect(active_user).to be_activated
          expect { change_email rescue nil }.not_to change { duplicate.reload.email }
        end
      end
    end
  end

  describe '#authenticate_api' do
    subject(:authenticate) { manager.authenticate_api }

    context 'token is not provided' do
      let(:api_token) { nil }
      specify { expect { authenticate }.to raise_error(AuthenticationError) }
    end

    context 'invalid token provided' do
      let(:api_token) { 'invalid' }
      specify { expect { authenticate }.to raise_error(AuthenticationError) }
    end

    context 'valid token' do
      let(:user) { create(:user) }
      let(:api_token) { user.api_token }

      specify { expect(authenticate).to eq(user) }
    end
  end
end
