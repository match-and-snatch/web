require 'spec_helper'

describe Api::StatusPostsController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'GET #new' do
    subject { get :new }

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
    subject { post 'create', message: 'Reply', format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(owner.api_token) }

      it { should be_success }
    end
  end
end
