require 'spec_helper'

describe Dashboard::Sales::ProfileOwnersController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    let(:sales) { create(:user, :sales) }

    context 'as an admin' do
      before { sign_in sales }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end

    context 'filter applied' do
      before { sign_in sales }

      subject { get :index, params: {filter: 'payout_updated'} }

      it { is_expected.to be_success }
    end
  end
end
