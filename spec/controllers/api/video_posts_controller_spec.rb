require 'spec_helper'

describe Api::VideoPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'DELETE #cancel' do
    let!(:pending_video) { create_video_upload  owner }
    subject { delete :cancel }

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
    let!(:pending_video) { create_video_upload  owner }
    subject { post :create, title: 'aa', message: 'bb' }

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(owner.api_token)
      end

      it { should be_success }
    end

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end
  end
end
