require 'spec_helper'

describe MessagesManager do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, email: 'another_user@mail.com') }
  let(:message) { subject.create(message: 'test', target_user: target_user) }
  let(:dialogue) { message.dialogue }

  subject { described_class.new(user: user) }

  describe '#create' do
    it 'creates new message' do
      expect(subject.create(message: 'test', target_user: target_user)).to be_a Message
    end

    it 'creates message_created event' do
      expect { subject.create(message: 'test', target_user: target_user) }.to create_event(:message_created)
    end

    specify do
      expect { subject.create(message: 'test', target_user: target_user) }.to deliver_email(to: 'another_user@mail.com',
                                                                                            subject: 'New message on ConnectPal')
    end

    context 'user notifications disabled' do
      before { UserProfileManager.new(target_user).disable_message_notifications }

      specify do
        expect { subject.create(message: 'test', target_user: target_user) }.not_to deliver_email(to: 'another_user@mail.com')
      end
    end

    context 'target user is locked' do
      before { UserManager.new(target_user).lock }

      specify do
        expect { subject.create(message: 'test', target_user: target_user) }.not_to deliver_email(to: 'another_user@mail.com')
      end
    end

    context 'a few messages in a row' do
      let!(:dialogue) { subject.create(message: 'test', target_user: target_user).dialogue }

      context 'previous message was not read' do
        specify do
          expect { subject.create(message: 'test', target_user: target_user) }.not_to deliver_email(to: 'another_user@mail.com')
        end
      end

      context 'previous message was read' do
        before { described_class.new(user: target_user, dialogue: dialogue).mark_as_read }

        specify do
          expect { subject.create(message: 'test', target_user: target_user) }.to deliver_email(to: 'another_user@mail.com', subject: 'New message on ConnectPal')
        end
      end
    end
  end

  describe '#mark_as_read' do
    context 'as message creator' do
      it { expect { subject.mark_as_read }.not_to change { dialogue.reload.unread }.from(true) }
      it { expect { subject.mark_as_read }.not_to change { message.read? }.from(false) }
      it { expect { subject.mark_as_read }.not_to change { message.read_at }.from(nil) }
    end

    context 'as a receiving user' do
      it { expect { described_class.new(user: target_user, dialogue: dialogue).mark_as_read }.to change { dialogue.reload.unread }.from(true).to(false) }
      it { expect { described_class.new(user: target_user, dialogue: dialogue).mark_as_read }.to change { message.reload.read? }.from(false).to(true) }
      it 'sets read date', freeze: true do
        expect { described_class.new(user: target_user, dialogue: dialogue).mark_as_read }.to change { message.reload.read_at }.from(nil).to(Time.zone.now)
      end
    end
  end

  describe '#remove' do
    specify do
      expect { subject.remove }.to change { dialogue.dialogues_users.where(user_id: user.id).first.removed? }.from(false).to(true)
    end

    specify do
      expect { subject.remove }.not_to change { dialogue.dialogues_users.where(user_id: target_user.id).first.removed? }
    end

    describe 'persistance' do
      before do
        user
        target_user
      end

      specify do
        expect { described_class.new(user: user, dialogue: dialogue).remove }.not_to change { User.count }
      end
    end
  end
end
