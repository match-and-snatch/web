require 'spec_helper'

describe CommentsController do
  let(:poster) { create_user email: 'poster@gmail.com' }
  let(:commenter) { create_user email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create('some post') }

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
end