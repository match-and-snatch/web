require 'spec_helper'

describe Dashboard::Admin::ProfilesController, type: :controller do
  before { sign_in create(:user, :admin) }

  describe 'GET #index' do
    subject { get 'index', q: 'test' }
    before { update_index }
    it { should be_success }
  end

  describe 'PUT #make_public' do
    let(:user) { create :user, :profile_owner }
    subject { put 'make_public', id: user.id }
    its(:status) { should == 200}
  end

  describe 'PUT #make_private' do
    let(:user) { create :user, :public_profile }
    subject { put 'make_private', id: user.id }
    its(:status) { should == 200}
  end
end
