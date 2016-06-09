require 'spec_helper'

describe VideosController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post 'create', { transloadit: transloadit_video_data_params.to_json} }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:video_upload) { create_video_upload  owner }
    subject { delete 'destroy', id: video_upload.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end
end
