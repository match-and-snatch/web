require 'spec_helper'

describe Admin::RecentProfilesController, type: :controller do
  before { sign_in create_admin(email: 'admin@gmail.com') }

  describe 'GET #index' do
    subject { get 'index' }
    it { should be_success }

    context 'as a non admin' do
      before { sign_in create_user }
      it { should_not be_success }
    end
  end
end
