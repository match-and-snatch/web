require 'spec_helper'

describe Api::UsersController, type: :controller do
  describe 'GET #search' do
    before { create_profile_owner first_name: 'sergei', last_name: 'zinin', is_profile_owner: true, profile_name: 'serge zinin', cost: '123.0' }
    before { create_profile_owner first_name: 'serge', last_name: 'zeenin', email: 'serge@zee.ru', is_profile_owner: true }
    before { create_profile_owner first_name: 'dmitry', last_name: 'jakovlev', email: 'dimka@jak.com', is_profile_owner: true }

    subject { get 'search', q: 'serge zi' }

    specify do
      expect(JSON.parse(subject.body)).to include("data" => [
        {
          "access"=>{"owner"=>false, "subscribed"=>false},
          "name"=>"serge zinin",
          "slug"=>"sergeizinin",
          "types"=>[],
          "subscription_cost"=>13407,
          "cost"=>12300,
          "profile_picture_url"=>"set",
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0},
        {
          "access"=>{"owner"=>false, "subscribed"=>false},
          "name"=>"test",
          "slug"=>"sergezeenin",
          "types"=>[],
          "subscription_cost"=>2199,
          "cost"=>2000,
          "profile_picture_url"=>"set",
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0}
      ])
    end
  end

  describe 'GET #show' do
    let(:user) { create_user first_name: 'sergei', last_name: 'zinin', is_profile_owner: true }

    subject { get 'show', id: user.slug }

    context 'token is not provided' do
      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to include 'data' }
    end

    context 'token provided' do
      before do
        request.env['HTTP_AUTHORIZATION'] = token
      end

      context 'invalid token' do
        let(:token) { ActionController::HttpAuthentication::Token.encode_credentials('invalid') }

        its(:status) { is_expected.to eq(401) }
        its(:body) { is_expected.to include 'failed' }
      end

      context 'valid token' do
        let(:api_user) { create_user email: 'api@user.ru', api_token: 'test_token' }
        let(:token) { ActionController::HttpAuthentication::Token.encode_credentials(api_user.api_token) }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to include 'success' }
        its(:body) { is_expected.to include 'data' }
      end
    end
  end
end
