require 'spec_helper'

describe AccountInfo::MessagesController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:target_user) { create :user, email: 'target@gmail.com' }

    subject { post :create, params: {user_id: target_user.id, message: 'test'} }

    context 'authorized' do
      before { sign_in user }
      it { should be_success }

      context 'target user is invalid' do
        let(:target_user) { double('target_user', id: 5) }
        its(:status) { should == 404 }
      end
    end

    context 'unauthorized' do
      its(:status) { should == 401 }
    end
  end
end