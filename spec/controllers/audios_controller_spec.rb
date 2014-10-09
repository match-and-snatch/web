require 'spec_helper'

describe AudiosController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post 'create', transloadit_audio_data_params }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end

  describe 'GET #show' do
    let(:audio_upload) { create_audio_upload(owner, create_post: true).first }
    subject { get 'show', id: audio_upload.id, format: :xml }

    context 'unauthorized access' do
      its(:status) { should == 200 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }

      context 'itunes is not enabled' do
        before { UserProfileManager.new(owner).disable_itunes }
        its(:status) { should == 404 }
      end

      context 'post is not assigned' do
        let(:audio_upload) { create_audio_upload(owner, create_post: false).first }
        its(:status) { should == 404 }
      end
    end

    context 'no such upload' do
      let(:audio_upload) { double('upload', id: 5) }
      its(:status) { should == 404 }
    end
  end

  describe 'POST #reorder' do
    subject { get 'reorder', ids: [1,2,3] }

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'DELETE #destroy' do
    let(:audio_upload) { create_audio_upload(owner).first }
    subject { delete 'destroy', id: audio_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end
end

