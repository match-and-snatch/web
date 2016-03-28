require 'spec_helper'

describe Dashboard::Admin::TosAcceptorsController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in create(:user, :admin) }

  describe 'GET #search' do
    subject { get 'search', q: 'test' }
    it { is_expected.to be_success }
  end

  describe 'GET #index' do
    subject { get 'index' }
    it { is_expected.to be_success }

    context 'filtered' do
      subject { get 'index', accepted: 'f' }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #confirm_toggle_tos_acceptance' do
    subject { get 'confirm_toggle_tos_acceptance', id: user.id }
    it { is_expected.to be_success }
  end

  describe 'PUT #toggle_tos_acceptance' do
    subject { put 'toggle_tos_acceptance', id: user.id }
    it { is_expected.to be_success }
  end

  describe 'GET #confirm_reset_tos_acceptance' do
    subject { get 'confirm_reset_tos_acceptance' }
    it { is_expected.to be_success }
  end

  describe 'POST #reset_tos_acceptance' do
    subject { post 'reset_tos_acceptance' }
    it { is_expected.to be_success }
  end
end
