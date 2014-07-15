require 'spec_helper'

describe Admin::UsersController, type: :controller do
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
    context 'when user is admin' do
      let(:admin) { create_admin(email: 'another@gmail.com') }
      subject { put 'drop_admin', id: admin.id }

      its(:body) { should match_regex 'replace'}
      its(:status) { should == 200}
    end

    context 'when user is not admin' do
      let(:user) { create_user(email: 'anotheruser@gmail.com') }
      subject { put 'drop_admin', id: user.id }

      its(:body) { should match_regex 'failed'}
      its(:status) { should == 200}
    end
  end

  describe 'POST #login_as' do
    let(:user) { create_user(email: 'another@gmail.com') }
    subject { post 'login_as', id: user.id }
    its(:body) { should match_regex 'reload'}
    its(:status) { should == 200}
  end
end

