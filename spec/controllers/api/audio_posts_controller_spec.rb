require 'spec_helper'

describe Api::AudioPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'GET #new' do
    subject { get :new, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'DELETE #cancel' do
    subject { delete :cancel, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, title: 'audio', message: 'post', format: :json }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      let!(:pending_audio) { create_audio_upload(owner).first }

      it { should be_success }
    end

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end
end
