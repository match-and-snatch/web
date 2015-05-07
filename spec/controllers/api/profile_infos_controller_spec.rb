require 'spec_helper'

describe Api::ProfileInfosController, type: :controller do
  let(:user) { create_user api_token: 'tolken' }

  describe 'POST #create_profile' do
    subject(:perform_request) { post 'create_profile', cost: 10, profile_name: 'test' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }

      context 'already have profile created' do
        pending 'shows error'
      end
    end

    context 'unauthorized' do
      its(:status) { should eq(401) }
    end
  end

  describe 'PUT #enable_vacation_mode' do
    subject { put 'enable_vacation_mode', vacation_message: 'test' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_vacation_mode' do
    subject { post 'disable_vacation_mode' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end
end
