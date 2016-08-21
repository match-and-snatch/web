describe SessionManager, type: :request do
  subject(:manager) { described_class.new(cookies) }

  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'password' }

  describe '#login' do
    subject(:login) { manager.login(email, password) }

    context 'authorized user' do
      let!(:user) { create(:user, email: email) }

      specify do
        expect(user.auth_token).not_to be_blank
      end

      specify do
        expect { login }.to change { cookies['auth_token'] }.from(nil).to(user.auth_token)
      end

      context 'login with uppercased email' do
        subject(:login) { manager.login(email.upcase, password) }

        it { expect { login }.not_to raise_error }
        it { expect { login }.to change { cookies['auth_token'] }.from(nil).to(user.auth_token) }
      end

      context 'invalid byte sequence' do
        let(:password) { "password\255" }

        specify do
          expect { login }.not_to raise_error
        end
      end

      context 'password is nil' do
        let(:password) { nil }

        specify do
          expect { login }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(password: t_error(:empty)) }
        end
      end
    end

    context 'unauthorized user' do
      specify do
        expect { login }.to raise_error(ManagerError)
      end
    end
  end

  describe '#logout' do
    let!(:user) { create(:user, email: email) }

    before do
      manager.login(email, password)
    end

    specify do
      expect { manager.logout }.to change { cookies['auth_token'] }.from(user.auth_token).to('')
    end
  end

  describe '#current_user' do
    its(:current_user) { is_expected.to be_a CurrentUserDecorator }
    its(:current_user) { is_expected.not_to be_authorized }

    context 'authorized user' do
      let!(:user) { create(:user, email: email) }

      before do
        manager.login(email, password)
      end

      its(:current_user) { is_expected.to be_authorized }
    end
  end
end
