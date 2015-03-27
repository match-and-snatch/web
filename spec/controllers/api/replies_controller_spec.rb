require 'spec_helper'

describe Api::RepliesController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com', api_token: 'poster_token' }
  let(:commenter) { create_user email: 'commenter@gmail.com', api_token: 'commenter_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

  before do
    SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
  end

  describe 'POST #create' do
    subject { post 'create', comment_id: comment.id, message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      context 'as poster' do
        let(:token) { poster.api_token }
        it { should be_success }
      end

      context 'as subscriber' do
        let(:token) { commenter.api_token }
        it { should be_success }
      end
    end
  end
end
