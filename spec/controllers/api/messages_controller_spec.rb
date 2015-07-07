require 'spec_helper'

describe Api::MessagesController, type: :controller do
  let(:user) { create_user api_token: 'token' }
  let(:target_user) { create_user email: 'target@gmail.com' }

  describe 'POST #create' do
    subject { post 'create', message: 'test', user_id: target_user.slug }

    context 'authorized' do
      before { sign_in_with_token user.api_token }

      its(:status) { should eq(200) }

      context 'user is subscribed to target user' do
        before { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

        its(:status) { should eq(200) }
      end
    end
  end
end
