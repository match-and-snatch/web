require 'spec_helper'

describe Admin::ProfileTypesController do
  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index' }
    its(:status) { should == 200 }
  end

  describe 'POST #create' do
    subject { post 'create', {title: 'test'} }
    its(:status) { should == 200 }
  end

  describe 'DELETE #destroy' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }
    subject { delete 'destroy', id: profile_type.id }
    its(:status) { should == 200 }
  end
end