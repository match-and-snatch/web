require 'spec_helper'

describe Api::CommentsController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com', api_token: 'poster_token' }
  let(:commenter) { create_user email: 'commenter@gmail.com', api_token: 'commenter_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'GET #index' do
    subject { get 'index', post_id: _post.id }

    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    context 'unauthorized access' do
      let(:token) { commenter.api_token }
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      context 'as poster' do
        let(:token) { poster.api_token }
        it { should be_success }
      end

      context 'as subscriber' do
        before do
          SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
        end
        let(:token) { commenter.api_token }
        it { should be_success }
      end
    end
  end

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, message: 'Comment' }

    before do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
    end

    context 'unauthorized access' do
      let(:token) { commenter.api_token }
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      context 'as poster' do
        let(:token) { poster.api_token }
        it { should be_success }
      end

      context 'as subscriber' do
        before do
          SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
        end
        let(:token) { commenter.api_token }
        it { should be_success }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(poster) }
    let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

    subject { delete 'destroy', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(token)
      end

      context 'as comment owner' do
        let(:token) { commenter.api_token }
        it { should be_success }
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }
        its(:status) { should eq(200) }
      end
    end
  end
end
