require 'spec_helper'

RSpec.describe PendingPostsController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }
  before { sign_in owner }

  describe 'PUT #update' do
    subject(:perform_request) { put :update, params: {message: 'new message', title: 'new title'} }
    it { is_expected.to be_success }

    specify do
      expect { perform_request }.to change { owner.reload.pending_post.try(:message) rescue nil }.from(nil).to('new message')
    end

    specify do
      expect { perform_request }.to change { owner.reload.pending_post.try(:title) rescue nil }.from(nil).to('new title')
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
