require 'spec_helper'

describe AudiosController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }
  describe 'POST #create' do
    subject { post 'create', transloadit_audio_data_params }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'DELETE #destroy' do
    let(:audio_upload) { create_audios_upload(owner).first  }
    subject { delete 'destroy', id: audio_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end