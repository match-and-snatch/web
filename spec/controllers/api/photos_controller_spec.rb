require 'spec_helper'

describe Api::PhotosController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_photo_data_params.to_json }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:photo_upload) { create_photo_upload(owner).first }

    subject { delete 'destroy', id: photo_upload.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end
end
