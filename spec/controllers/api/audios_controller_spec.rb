require 'spec_helper'

describe Api::AudiosController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_audio_data_params.to_json }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'POST #reorder' do
    subject { get 'reorder', ids: [1, 2, 3] }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      its(:status) { should eq(200) }
    end

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end
  end

  describe 'DELETE #destroy' do
    let(:audio_upload) { create_audio_upload(owner).first }

    subject { delete 'destroy', id: audio_upload.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end
end
