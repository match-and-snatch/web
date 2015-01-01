describe UserFlow do
  let!(:performer) { nil }
  subject(:flow) { described_class.new(performer: performer) }

  describe '#create' do
    subject(:create) { flow.create(email: 'szinin@gmail.com', password: 'qwertyui', password_confirmation: 'qwertyui') }

    it { expect { create }.to change { User.count }.by(1) }
    it { expect { create }.to change { flow.user }.from(nil).to(instance_of(User)) }

    describe 'user' do
      before { create }
      subject(:user) { flow.user }

      it { expect(user.email).to eq('szinin@gmail.com') }
    end

    context 'invalid email' do
      subject(:create) { flow.create(email: 'szinin', password: 'qwertyui', password_confirmation: 'qwertyui') }

      it { expect { create }.not_to change { User.count } }
      it { expect { create }.not_to change { flow.user }.from(nil) }
      it { expect { create }.to change { flow.errors }.from({}).to(email: [:not_an_email]) }

      context 'not set' do
        subject(:create) { flow.create(email: '', password: 'qwertyui', password_confirmation: 'qwertyui') }

        it { expect { create }.not_to change { User.count } }
        it { expect { create }.not_to change { flow.user }.from(nil) }
        it { expect { create }.to change { flow.errors }.from({}).to(email: [:cannot_be_empty, :not_an_email]) }
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