require 'spec_helper'

describe Admin::UsersController do
  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index', q: 'test' }
    it { should be_success }
  end

  describe 'PUT #make_admin' do
    let(:user) { create_user(email: 'another@gmail.com') }
    subject { put 'make_admin', id: user.id }
    its(:status) { should == 200}
  end

  describe 'PUT #drop_admin' do
    let(:user) { create_user(email: 'another@gmail.com') }
    subject { put 'drop_admin', id: user.id }
    its(:status) { should == 200}
  end
end
