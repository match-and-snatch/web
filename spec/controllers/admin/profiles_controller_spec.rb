require 'spec_helper'

describe Admin::ProfilesController do
  before { sign_in create_admin }

  describe 'GET #new' do
    subject { get 'new' }
    it { should be_success }
  end

  describe 'GET #index' do
    subject { get 'index', q: 'test' }
    it { should be_success }
  end

  describe 'PUT #make_public' do
    let(:user) { create_user(email: 'another@gmail.com') }
    subject { put 'make_public', id: user.id }
    its(:status) { should == 200}
  end

  describe 'PUT #make_private' do
    let(:user) { UserProfileManager.new(create_user(email: 'another@gmail.com')).make_profile_public }
    subject { put 'make_private', id: user.id }
    its(:status) { should == 200}
    its(:body) { should match_regex /replace/ }
  end

  describe 'GET #profile_owners' do
    let(:profile)  { create_profile(email: 'another@gmail.com') }
    let(:profile1) { create_profile(email: 'another1@gmail.com') }
    subject(:perform_request) { get 'profile_owners' }

    before { perform_request  }
    it { expect(assigns(:users)).to eq([profile, profile1]) }

    its(:body) { should match_regex /success/ }
    its(:status) { should == 200}
  end
end
