require 'spec_helper'

describe Api::AccountInfosController, type: :controller do
  let(:user) { create_user email: 'user@gmail.com', api_token: 'user_token' }
  let(:set_token) do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.api_token)
  end
  
  describe 'GET #settings' do
    subject { get 'settings' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #update_account_picture' do
    subject { put 'update_account_picture', transloadit: profile_picture_data_params.to_json }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put 'update_general_information' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put 'update_cc_data' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #enable_rss' do
    subject { put 'enable_rss' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #disable_rss' do
    subject { put 'disable_rss' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #enable_downloads' do
    subject { put 'enable_downloads' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #disable_downloads' do
    subject { put 'disable_downloads' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #enable_itunes' do
    subject { put 'enable_itunes' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end

  describe 'PUT #disable_itunes' do
    subject { put 'disable_itunes' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { set_token }
      it { should be_success }
    end
  end
end
