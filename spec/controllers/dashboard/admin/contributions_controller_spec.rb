require 'spec_helper'

describe Dashboard::Admin::ContributionsController, type: :controller do
  let(:contribution) { create(:contribution, recurring: true) }

  before { sign_in create(:user, :admin) }

  describe 'GET #confirm_cancel' do
    subject { get :confirm_cancel, params: {id: contribution.id} }
    it { is_expected.to be_success }
  end

  describe 'PUT #confirm_cancel' do
    subject { put :confirm_cancel, params: {id: contribution.id} }
    it { is_expected.to be_success }
  end
end
