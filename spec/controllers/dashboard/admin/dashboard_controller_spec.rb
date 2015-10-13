require 'spec_helper'

describe Dashboard::Admin::DashboardsController, type: :controller do
  describe 'GET #show' do
    subject { get 'show' }

    context 'as an admin' do
      before { sign_in create_admin }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { should_not be_success }
    end
  end
end