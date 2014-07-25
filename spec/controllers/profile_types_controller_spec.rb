require 'spec_helper'

describe ProfileTypesController, type: :controller do
  before { sign_in }

  describe 'GET #index' do
    subject { get 'index', q: 'test' }
    it { should be_success }
  end

  describe 'POST #create' do
    context 'profile type does not exist' do
      subject { post 'create', type: 'test' }
      it { should be_success }
    end

    context 'profile type does exist' do
      subject { post 'create', type: 'test' }
      before { ProfileTypeManager.new.create(title: 'test') }
      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    context 'profile type does not exist' do
      subject { delete 'destroy', id: 1 }
      it { should_not be_success }
    end

    context 'profile type does exist' do
      subject { delete 'destroy', id: profile_type.id }
      let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }
      it { should be_success }
    end
  end
end