require 'spec_helper'

describe Api::AccountInfosController, type: :controller do
  let(:user) { create_user email: 'user@gmail.com', api_token: 'user_token' }
  
  describe 'GET #settings' do
    subject { get 'settings' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'GET #billing_information' do
    subject { get 'billing_information' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #update_account_picture' do
    subject { put 'update_account_picture', transloadit: profile_picture_data_params.to_json }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put 'update_general_information' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put 'update_cc_data' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end
end
