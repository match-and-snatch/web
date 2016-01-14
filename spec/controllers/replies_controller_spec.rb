require 'spec_helper'

describe RepliesController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com' }
  let(:commenter) { create_user email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
  let(:reply) { CommentManager.new(user: commenter, post: _post, parent: comment).create(message: 'reply') }

  describe 'GET #show' do
    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(poster) }
    subject { get 'show', comment_id: comment.id, id: reply.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should eq(401) }
      end
    end
  end
end
