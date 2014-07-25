require 'spec_helper'

describe Admin::ProfileTypesController, type: :controller do
  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index' }
    it { should be_success }
  end

  describe 'POST #create' do
    subject { post 'create', {title: 'test'} }
    it { should be_success }
  end

  describe 'DELETE #destroy' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }
    subject { delete 'destroy', id: profile_type.id }
    it { should be_success }
  end
end