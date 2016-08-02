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
    subject { post 'create', tos: 'ToS' }
    it { is_expected.to be_success }
  end

  describe 'PUT #publish' do
    subject { put 'publish', id: tos_version.id }
    it { is_expected.to be_success }
  end

  describe 'GET #text' do
    subject { get 'text', id: tos_version.id }
    it { is_expected.to be_success }
  end
end
