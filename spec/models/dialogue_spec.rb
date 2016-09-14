describe Dialogue do
  let(:user) { create(:user) }
  let(:friend) { create(:user, email: 'sender@gmail.com') }
  let(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }

  describe '.pick' do
    context 'dialogue does exist' do
      subject { described_class.pick(user, friend) }
      specify { expect(subject).to eq(dialogue) }
    end

    context 'dialogue does not exist' do
      let(:another_user) { create(:user, email: 'another@user.ru') }
      subject { described_class.pick(another_user, friend) }

      specify { expect(subject).not_to eq(dialogue) }

      specify do
        expect { subject }.to change { Dialogue.count }.by(1)
      end

      specify do
        expect(subject).to be_a(Dialogue)
      end

      specify do
        expect(subject.users).to include(friend, another_user)
      end
    end
  end

  describe '#antiuser' do
    specify do
      expect(dialogue.antiuser(user)).to eq(friend)
    end

    specify do
      expect(dialogue.antiuser(friend)).to eq(user)
    end
  end
end
