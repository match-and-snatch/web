require 'spec_helper'

describe Dialogue do
  let(:user) { create_user }
  let(:friend) { create_user email: 'sender@gmail.com' }

  subject(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }

  describe '.pick' do
    subject { described_class.pick(user, friend).id }

    specify { expect(subject).to eq(dialogue.id) }

    context 'removed dialogue' do
      before { dialogue.remove! }

      specify { expect(subject).not_to eq(dialogue.id) }
    end
  end

  describe '#remove!' do
    specify { expect { dialogue.remove! }.to change { dialogue.removed }.from(false).to(true) }
    specify { expect { dialogue.remove! }.to change { dialogue.removed_at }.from(nil) }
  end
end