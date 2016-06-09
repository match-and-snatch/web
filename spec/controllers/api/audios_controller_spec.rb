require 'spec_helper'

describe Api::AudiosController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_audio_data_params.to_json, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'POST #reorder' do
    subject { get 'reorder', ids: [1, 2, 3], format: :json }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      its(:status) { should eq(200) }
    end

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end

  describe 'DELETE #destroy' do
    let(:audio_upload) { create_audio_upload(owner).first }

    subject { delete 'destroy', id: audio_upload.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end
end
