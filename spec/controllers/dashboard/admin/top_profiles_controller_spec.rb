require 'spec_helper'

describe Dashboard::Admin::TopProfilesController, type: :controller do
  let(:profile) { create_profile email: 'profile@gmail.com' }
  let(:top_profile) { profile.create_top_profile }

  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index' }
    it { should be_success }
  end

  describe 'GET #search' do
    subject { get 'search', q: 'test' }
    it { should be_success }
  end

  describe 'PUT #create' do
    subject { put 'create', user_id: profile.id }
    it { should be_success }
  end

  describe 'GET #edit' do
    subject { get 'edit', id: top_profile.id }
    it { should be_success }

    context 'no top_profile present' do
      subject { get 'edit', id: 0 }
      its(:status) { should == 404 }
    end
  end

  describe 'PUT #update' do
    subject { put 'update', id: top_profile.id, profile_name: 'Profile', profile_types_text: 'Types' }
    it { should be_success }

    context 'no top_profile present' do
      subject { put 'update', id: 0, profile_name: 'Profile', profile_types_text: 'Types' }
      its(:status) { should == 404 }
    end
  end

  describe 'POST #update_list' do
    subject { post 'update_list', ids: [top_profile.id] }
    it { should be_success }
  end

  describe 'DELETE #destroy' do
    subject { delete 'destroy', id: top_profile.id }
    it { should be_success }

    context 'no top_profile present' do
      subject { delete 'destroy', id: 0 }
      its(:status) { should == 404 }
    end
  end
end
