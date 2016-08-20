require 'spec_helper'

describe Dashboard::Admin::TopProfilesController, type: :controller do
  let(:profile) { create :user, :profile_owner }
  let(:top_profile) { profile.create_top_profile }

  before { sign_in create(:user, :admin) }

  describe 'GET #index' do
    subject { get 'index' }
    it { should be_success }
  end

  describe 'GET #search' do
    before { update_index { profile } }
    subject { get :search, params: {q: 'test'} }
    it { should be_success }
  end

  describe 'PUT #create' do
    subject { put :create, params: {user_id: profile.id} }
    it { should be_success }
  end

  describe 'GET #edit' do
    subject { get :edit, params: {id: top_profile.id} }
    it { should be_success }

    context 'no top_profile present' do
      subject { get :edit, params: {id: 0} }
      its(:status) { should == 404 }
    end
  end

  describe 'PUT #update' do
    subject { put :update, params: {id: top_profile.id, profile_name: 'Profile', profile_types_text: 'Types'} }
    it { should be_success }

    context 'no top_profile present' do
      subject { put :update, params: {id: 0, profile_name: 'Profile', profile_types_text: 'Types'} }
      its(:status) { should == 404 }
    end
  end

  describe 'POST #update_list' do
    subject { post :update_list, params: {ids: [top_profile.id]} }
    it { should be_success }
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: {id: top_profile.id} }
    it { should be_success }

    context 'no top_profile present' do
      subject { delete :destroy, params: {id: 0} }
      its(:status) { should == 404 }
    end
  end
end
