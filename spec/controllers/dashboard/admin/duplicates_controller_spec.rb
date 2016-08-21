require 'spec_helper'

RSpec.describe Dashboard::Admin::DuplicatesController, type: :controller do
  let(:admin) { create(:user, :admin) }
  let(:user) { create(:user) }

  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_mark_as_duplicate' do
    subject { get :confirm_mark_as_duplicate, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'PUT #mark_as_duplicate' do
    subject { put :mark_as_duplicate, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end
end
