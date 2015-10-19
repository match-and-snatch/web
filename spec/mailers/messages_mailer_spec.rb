require 'spec_helper'

describe MessagesMailer do
  describe '#new_nessage' do
    let(:user) { create_user }
    let(:target_user) { create_user email: 'another_user@mail.com' }
    let!(:message) { MessagesManager.new(user: user).create(message: 'test', target_user: target_user) }

    subject(:send_email) { described_class.new_message(message.reload).deliver_now }

    it { expect { send_email }.to deliver_email(to: target_user, subject: 'New message on ConnectPal') }

    context 'message is read' do
      before { MessagesManager.new(user: target_user, dialogue: message.dialogue).mark_as_read }

      it { expect { send_email }.not_to deliver_email(to: target_user, subject: 'New message on ConnectPal') }
    end
  end
end
