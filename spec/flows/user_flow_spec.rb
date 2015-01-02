describe UserFlow do
  subject(:flow) { described_class.new }

  describe '#create' do
    subject(:create) { flow.create(email: 'szinin@gmail.com', password: 'qwertyui', password_confirmation: 'qwertyui') }

    it { expect { create }.to change { User.count }.by(1) }
    it { expect { create }.to change { flow.user }.from(nil).to(instance_of(User)) }

    describe 'user' do
      before { create }
      subject(:user) { flow.user }

      it { expect(user.email).to eq('szinin@gmail.com') }
      it { expect(user.password_salt).to be_present }
      it { expect(user.password_hash).to be_present }
      it { expect(user.auth_token).to be_present }
      it { expect(user.registration_token).to be_present }
    end

    context 'invalid email' do
      context 'invalid format' do
        subject(:create) { flow.create(email: 'szinin', password: 'qwertyui', password_confirmation: 'qwertyui') }

        it { expect { create }.not_to change { User.count } }
        it { expect { create }.not_to change { flow.user }.from(nil) }
        it { expect { create }.to change { flow.errors }.from({}).to(email: [:not_an_email]) }
      end

      context 'not set' do
        subject(:create) { flow.create(email: '', password: 'qwertyui', password_confirmation: 'qwertyui') }

        it { expect { create }.not_to change { User.count } }
        it { expect { create }.not_to change { flow.user }.from(nil) }
        it { expect { create }.to change { flow.errors }.from({}).to(email: [:cannot_be_empty, :not_an_email]) }
      end

      context 'already taken' do
        before do
          described_class.new.create(email: 'szinin@gmail.com', password: '1234567', password_confirmation: '1234567')
        end

        subject(:create) { flow.create(email: 'szinin@gmail.com', password: 'qwertyui', password_confirmation: 'qwertyui') }

        it { expect { create }.not_to change { User.count } }
        it { expect { create }.not_to change { flow.user }.from(nil) }
        it { expect { create }.to change { flow.errors }.from({}).to(email: [:already_taken]) }
      end
    end

    context 'short password' do
      subject(:create) { flow.create(email: 'szinin@gmail.com', password: 'qwer', password_confirmation: 'qwer') }

      it { expect { create }.not_to change { User.count } }
      it { expect { create }.not_to change { flow.user }.from(nil) }
      it { expect { create }.to change { flow.errors }.from({}).to(password: [:too_short]) }
    end

    context 'confirmation does not match password' do
      subject(:create) { flow.create(email: 'szinin@gmail.com', password: 'qwertyui', password_confirmation: '123456') }

      it { expect { create }.not_to change { User.count } }
      it { expect { create }.not_to change { flow.user }.from(nil) }
      it { expect { create }.to change { flow.errors }.from({}).to(password_confirmation: [:does_not_match]) }
    end
  end
end