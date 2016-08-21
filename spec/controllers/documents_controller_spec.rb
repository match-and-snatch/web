require 'spec_helper'

RSpec.describe DocumentsController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post :create, params: {transloadit: transloadit_document_data_params.to_json} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:document_upload) { create(:document, user: owner) }
    subject { delete :destroy, params: {id: document_upload.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end
end
