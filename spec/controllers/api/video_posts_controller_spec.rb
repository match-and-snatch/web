require 'spec_helper'

describe Api::VideoPostsController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'DELETE #cancel' do
    let!(:pending_video) { create_video_upload  owner }
    subject { delete :cancel, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(owner.api_token)
      end

      it { should be_success }
    end
  end

  describe 'GET #new' do
    subject { get :new, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
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
    subject { post :create, title: 'aa', message: 'bb', format: :json }

    context 'authorized access' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(owner.api_token)
      end

      it { should be_success }
    end

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end
end
