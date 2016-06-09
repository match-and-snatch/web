require 'spec_helper'

describe FeedsController, type: :controller do
  describe 'GET #show' do
    subject(:request_perform) { get 'show' }

    context 'authorized access' do
      let(:user) { create(:user) }
      let(:subscriber) { create :user, email: 'subscriber@gmail.com' }
      let!(:_post) do
        SubscriptionManager.new(subscriber: subscriber).subscribe_to(user)
        PostManager.new(user: user).create_status_post(message: 'aloha')
      end

      before { sign_in subscriber }
      before { request_perform }

      it{ expect(assigns(:feed_events).count).to eq(1) }
      its(:body) { should match_regex /success/ }
      it { should be_success }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end
