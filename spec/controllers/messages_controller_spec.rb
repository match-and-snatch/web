require 'spec_helper'

describe MessagesController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create :user, email: 'target@gmail.com' }

  describe 'GET #new' do
    subject { get 'new', user_id: target_user.id }

    context 'authorized' do
      before { sign_in user }
      its(:status) { should == 401 }

      context 'user is subscribed to target user' do
        before { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }
        its(:status) { should == 200 }
      end
    end

    context 'non authorized' do
      its(:status) { should == 401 }
    end
  end

  describe 'POST #create' do
    subject { post 'create', message: 'test', user_id: target_user.id }

    context 'authorized' do
      before { sign_in user }
      its(:status) { should == 401 }

      context 'user is subscribed to target user' do
        before { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }
        its(:status) { should == 200 }
      end
    end

    context 'non authorized' do
      its(:status) { should == 401 }
    end
  end
end

