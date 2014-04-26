require 'spec_helper'

describe FeedsController do
  describe 'GET #show' do
    subject(:request_perform) { get 'show' }

    context 'authorized acesss' do
      let(:user){ create_user }
      let(:subsciber){ create_user email: 'subsciber@gmail.com' }
      let!(:_post) do
        SubscriptionManager.new(subsciber).subscribe_to(user)
        PostManager.new(user: user).create_status_post(message: 'aloha')
      end

      before { sign_in subsciber }
      before { request_perform }

      it{ expect(assigns(:feed_events).count).to eq(1) }
      its(:body) { should match_regex /success/ }
      its(:status) { should == 200 }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end
