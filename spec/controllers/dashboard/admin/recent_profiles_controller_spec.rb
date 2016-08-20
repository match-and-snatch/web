require 'spec_helper'

describe Dashboard::Admin::RecentProfilesController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    context 'as admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }

      context 'filtered' do
        subject { get :index, params: {filter: 'with_posts'} }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end
end
