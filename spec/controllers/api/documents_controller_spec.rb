require 'spec_helper'

describe Api::DocumentsController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_document_data_params.to_json, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:document_upload) { create(:document, user: owner) }

    subject { delete 'destroy', id: document_upload.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end
end
