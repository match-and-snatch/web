require 'spec_helper'

describe PostManager do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user: user) }

  describe '#create' do
    specify do
      expect(manager.create('some text')).to be_a Post
    end

    specify do
      expect(manager.create('some text')).to be_persisted
    end
  end

  describe '#update_pending' do
    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_a PendingPost
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_persisted
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword').message).to eq('message')
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword').user).to eq(user)
    end

    context 'already created' do
      before do
        manager.update_pending(message: 'message', keywords: 'keyword')
      end

      specify do
        expect { manager.update_pending(message: 'new one') }.to change { user.pending_post.message }.from('message').to('new one')
      end

      specify do
        expect { manager.update_pending(keywords: 'new one') }.to change { user.pending_post.keywords }.from('keyword').to('new one')
      end
    end
  end
end