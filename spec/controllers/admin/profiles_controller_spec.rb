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
    let(:user) { create_user(email: 'another@gmail.com') }
    subject { put 'make_private', id: user.id }
    its(:status) { should == 200}
  end
end