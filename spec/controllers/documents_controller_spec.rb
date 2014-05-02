require 'spec_helper'

describe DocumentsController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'POST #create' do
    subject { post 'create', transloadit_document_data_params }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'DELETE #destroy' do
    let(:document_upload) { create_documents_upload(owner).first  }
    subject { delete 'destroy', id: document_upload.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end
end
