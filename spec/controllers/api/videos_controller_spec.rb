require 'spec_helper'

describe Api::VideosController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_video_data_params.to_json, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:video_upload) { create_video_upload  owner }

    subject { delete 'destroy', id: video_upload.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end
end
