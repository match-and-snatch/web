require 'spec_helper'

describe Api::StatusPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'GET #new' do
    subject { get :new }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(owner.api_token)
      end

      it { should be_success }
    end
  end

  describe 'POST #create' do
    subject { post 'create', message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(owner.api_token) }

      it { should be_success }
    end
  end
end