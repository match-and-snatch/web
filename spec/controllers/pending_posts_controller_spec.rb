require 'spec_helper'

describe PendingPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }
  before { sign_in owner }

  describe 'PUT #update' do
    subject(:perform_request) { put :update, message: 'new message', title: 'new title' }
    it { should be_success }

    specify do
      expect { perform_request }.to change { owner.pending_post(true).try(:message) }.from(nil).to('new message')
    end

    specify do
      expect { perform_request }.to change { owner.pending_post(true).try(:title) }.from(nil).to('new title')
    end

    context 'already has pending post created' do
      before do
        PostManager.new(user: owner).update_pending(message: 'old message', title: 'old title')
      end

      specify do
        expect { perform_request }.to change { owner.pending_post.reload.message }.from('old message').to('new message')
      end

      specify do
        expect { perform_request }.to change { owner.pending_post.reload.title }.from('old title').to('new title')
      end
    end
  end
end
