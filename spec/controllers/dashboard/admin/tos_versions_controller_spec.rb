require 'spec_helper'

describe Dashboard::Admin::TosVersionsController, type: :controller do
  let(:user) { create(:user) }
  let(:tos_version) { create(:tos_version) }

  before { sign_in create(:user, :admin) }

  describe 'GET #index' do
    subject { get 'index' }
    it { is_expected.to be_success }
  end

  describe 'GET #new' do
    subject { get 'new' }
    it { is_expected.to be_success }
  end

  describe 'POST #create' do
    subject { post :create, params: {tos: 'ToS', privacy_policy: 'PP'} }
    it { is_expected.to be_success }
  end

  describe 'GET #edit' do
    subject { get 'edit', id: tos_version.id }
    it { is_expected.to be_success }
  end

  describe 'PATCH #update' do
    subject { patch :update, params: {id: tos_version.id, tos: 'ToS edited', privacy_policy: 'PP edited'} }
    it { is_expected.to be_success }
  end

  describe 'PUT #publish' do
    subject { put :publish, params: {id: tos_version.id} }
    it { is_expected.to be_success }
  end

  describe 'GET #show' do
    subject { get :show, params: {id: tos_version.id} }
  end

  describe 'GET #text' do
    subject { get :text, params: {id: tos_version.id} }
    it { is_expected.to be_success }
  end

  describe 'GET #confirm_toggle_acceptance_requirement' do
    subject { get 'confirm_toggle_acceptance_requirement', id: tos_version.id }
    it { is_expected.to be_success }
  end

  describe 'PUT #toggle_acceptance_requirement' do
    subject { put 'toggle_acceptance_requirement', id: tos_version.id }
    it { is_expected.to be_success }
  end
end
