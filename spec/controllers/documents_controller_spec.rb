require 'spec_helper'

describe DocumentsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post 'create', transloadit: transloadit_document_data_params.to_json }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:document_upload) { create_document_upload(owner).first  }
    subject { delete 'destroy', id: document_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end
end
