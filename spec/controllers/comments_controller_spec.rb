require 'spec_helper'

describe CommentsController do
  let(:poster) { create_user email: 'poster@gmail.com' }
  let(:commenter) { create_user email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'GET #index' do
    subject { get 'index', post_id: _post.id }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as subscriber' do
        before { SubscriptionManager.new(commenter).subscribe_to(poster) }
        before { sign_in commenter }
        its(:status) { should == 200 }
      end
    end
  end

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, message: 'Reply' }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as subscriber' do
        before { SubscriptionManager.new(commenter).subscribe_to(poster) }
        before { sign_in commenter }
        its(:status) { should == 200 }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:comment){ _post.comments.create(message: 'hello', user_id: commenter.id) }
    subject { delete 'destroy', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        its(:status) { should == 200 }
      end

      context 'as not comment owner' do
        before { sign_in poster }
        its(:status) { should == 401 }
      end
    end
  end
end
