require 'spec_helper'

describe ContributionsController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, :profile_owner) }

  describe 'GET #index' do
    subject { get 'index' }

    before { create(:contribution, target_user: target_user, user: user) }

    context 'authorized' do
      before { sign_in target_user }
      its(:status) { is_expected.to eq(200) }
    end

    context 'non authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'request with year' do
      subject { get :index, params: {year: 2015} }

      before { sign_in target_user }

      its(:status) { is_expected.to eq(200) }
    end
  end

  describe 'GET #new' do
    subject { get :new, params: {target_user_id: target_user.id} }

    context 'authorized' do
      before { sign_in user }
      its(:status) { is_expected.to eq(200) }
    end

    context 'non authorized' do
      its(:status) { is_expected.to eq(200) }
    end

    context 'request without target_user_id' do
      subject { get 'new' }
      its(:status) { is_expected.to eq(200) }
    end
  end
end
