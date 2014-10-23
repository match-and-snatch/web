require 'spec_helper'

describe Admin::RecentProfilesController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    context 'as admin' do
      before { sign_in create_admin(email: 'admin@gmail.com') }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { should_not be_success }
    end
  end
end
