require 'spec_helper'

describe VideosController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post 'create', transloadit_video_data_params }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'DELETE #destroy' do
    let(:video_upload) { create_video_upload  owner }
    subject { delete 'destroy', id: video_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end