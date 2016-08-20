require 'spec_helper'

describe Api::MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, email: 'target@gmail.com') }

  describe 'POST #create' do
    subject { post :create, params: {message: 'test', user_id: target_user.id}, format: :json }

    context 'authorized' do
      before { sign_in_with_token user.api_token }

      its(:status) { should eq(200) }

      context 'user is subscribed to target user' do
        before { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

        its(:status) { should eq(200) }
        it { expect(JSON.parse(subject.body)).to include({'status'=>'success'}) }
      end
    end
  end
end
