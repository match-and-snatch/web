require 'spec_helper'

describe Api::RepliesController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com', api_token: 'poster_token' }
  let(:commenter) { create_user email: 'commenter@gmail.com', api_token: 'commenter_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
  let(:reply) { CommentManager.new(user: commenter, post: _post, parent: comment).create(message: 'reply') }
  let(:anybody_else) { create_user email: 'anybody@gmail.com', api_token: 'anybody_token' }

  before do
    SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
  end

  describe 'POST #create' do
    subject { post 'create', comment_id: comment.id, message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

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

  describe 'PUT #update' do
    subject(:perform_request) { put 'update', comment_id: comment.id, id: reply.id, message: 'updated' }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { should be_success }

        specify do
          expect { perform_request }.to change { reply.reload.message }.to('updated')
        end
      end

      context 'as a post owner' do
        let(:token) { commenter.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        its(:status) { should eq(401) }
      end
    end
  end

  describe 'PUT #make_visible' do
    before do
      CommentManager.new(user: poster, comment: reply).hide
    end

    subject(:perform_request) { put 'make_visible', comment_id: comment.id, id: reply.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { should be_success }

        specify do
          expect { perform_request }.to change { reply.reload.hidden? }.to(false)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        its(:status) { should eq(401) }
      end
    end
  end

  describe 'PUT #hide' do
    subject(:perform_request) { put 'hide', comment_id: comment.id, id: reply.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { should be_success }

        specify do
          expect { perform_request }.to change { reply.reload.hidden? }.to(true)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        its(:status) { should eq(401) }
      end
    end
  end
end
