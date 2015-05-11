require 'spec_helper'

describe Api::ProfileInfosController, type: :controller do
  let(:user) { create_user api_token: 'token' }

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

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_rss' do
    subject { put 'enable_rss' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_rss' do
    subject { put 'disable_rss' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_downloads' do
    subject { put 'enable_downloads' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_downloads' do
    subject { put 'disable_downloads' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_itunes' do
    subject { put 'enable_itunes' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_itunes' do
    subject { put 'disable_itunes' }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
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
