require 'spec_helper'

describe Api::UsersController, type: :controller do
  describe 'GET #show' do
    let(:user) { create_user first_name: 'sergei', last_name: 'zinin', is_profile_owner: true }

    subject { get 'show', id: user.slug }

    context 'token is not provided' do
      its(:status) { is_expected.to eq(401) }
      its(:body) { is_expected.to include 'required' }
    end

    context 'token provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] = token
      end

      context 'invalid token' do
        let(:token) { ActionController::HttpAuthentication::Token.encode_credentials('invalid') }

        its(:status) { is_expected.to eq(401) }
        its(:body) { is_expected.to include 'invalid' }
      end

      context 'valid token' do
        let(:api_user) { create_user email: 'api@user.ru', api_token: 'test_token' }
        let(:token) { ActionController::HttpAuthentication::Token.encode_credentials(api_user.api_token) }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to include 'success' }
      end
    end
  end
end
