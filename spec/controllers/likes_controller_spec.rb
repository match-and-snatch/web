require 'spec_helper'

describe LikesController, type: :controller do
  let(:poster) { create :user, email: 'poster@gmail.com' }
  let(:visitor) { create :user, email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'POST #create' do
    subject { post :create, params: {post_id: _post.id, type: 'post'} }

    context 'authorized access' do
      before { sign_in visitor }

      context 'subscribed' do
        before { SubscriptionManager.new(subscriber: visitor).subscribe_to(poster) }

        its(:status) { should eq(200) }
        its(:body) { should match_regex /replace/ }
      end

      context 'not subscribed' do
        its(:status) { should eq(401) }
      end
    end
  end
end

