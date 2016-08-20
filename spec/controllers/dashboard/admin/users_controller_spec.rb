require 'spec_helper'

describe Dashboard::Admin::UsersController, type: :controller do
  before { sign_in create(:user, :admin) }

  describe 'PUT #make_admin' do
    let(:user) { create(:user, email: 'another@gmail.com') }
    subject { put :make_admin, params: {id: user.id} }
    its(:status) { should == 200}
  end

  describe 'PUT #drop_admin' do
    context 'when user is admin' do
      let(:admin) { create(:user, :admin, email: 'another@gmail.com') }
      subject { put :drop_admin, params: {id: admin.id} }

      its(:status) { should == 200}
    end

    context 'when user is not admin' do
      let(:user) { create(:user, email: 'anotheruser@gmail.com') }
      subject { put :drop_admin, params: {id: user.id} }

      its(:body) { should match_regex 'failed'}
      its(:status) { should == 200}
    end
  end

  describe 'POST #login_as' do
    let(:user) { create(:user, email: 'another@gmail.com') }
    subject { post :login_as, params: {id: user.id} }
    its(:body) { should match_regex 'redirect'}
    its(:status) { should == 200}
  end
end
