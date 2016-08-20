require 'spec_helper'

describe Dashboard::Admin::ProfileOwnersController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    let(:admin) { create(:user, :admin) }

    context 'as an admin' do
      before { sign_in admin }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { should_not be_success }
    end

    context 'filter applied' do
      before { sign_in admin }

      subject { get :index, params: {filter: 'payout_updated'} }

      it { should be_success }
    end
  end
end
