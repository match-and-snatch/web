require 'spec_helper'

RSpec.describe VideosController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post :create, params: {transloadit: transloadit_video_data_params.to_json} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:video_upload) { create(:video, user: owner) }
    subject { delete :destroy, params: {id: video_upload.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end
end
