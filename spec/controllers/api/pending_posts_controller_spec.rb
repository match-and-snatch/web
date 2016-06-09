require 'spec_helper'

describe Api::PendingPostsController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }
  before do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(owner.api_token)
  end

  describe 'PUT #update' do
    subject(:perform_request) { put :update, message: 'new message', title: 'new title', format: :json }
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
