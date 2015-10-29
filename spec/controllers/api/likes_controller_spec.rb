require 'spec_helper'

describe Api::LikesController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com' }
  let(:visitor) { create_user email: 'commenter@gmail.com', api_token: 'test_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, type: 'post', format: :json }

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(visitor.api_token)
      end

      context 'subscribed' do
        before { SubscriptionManager.new(subscriber: visitor).subscribe_to(poster) }

        its(:status) { should eq(200) }
      end

      context 'not subscribed' do
        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end
end
