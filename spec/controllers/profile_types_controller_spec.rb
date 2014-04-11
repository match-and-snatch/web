require 'spec_helper'

describe ProfileTypesController do
  before { sign_in }

  describe 'GET #index' do
    subject { get 'index', q: 'test' }
    it { should be_success }
  end

  describe 'POST #create' do
    context 'profile type does not exist' do
      subject { post 'create', profile_type_id: 1 }
      it { should_not be_success }
    end

    context 'profile type does exist' do
      subject { post 'create', profile_type_id: profile_type.id }
      let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }
      it { should be_success }
    end
  end
end