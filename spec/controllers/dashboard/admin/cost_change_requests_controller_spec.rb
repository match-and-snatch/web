require 'spec_helper'

describe Dashboard::Admin::CostChangeRequestsController, type: :controller do
  let(:user) { create_profile(email: 'profile@mail.com') }
  let(:cost_change_request) { CostChangeRequest.create!(user: user, old_cost: user.cost, new_cost: 800) }

  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_reject' do
    subject { get 'confirm_reject', id: cost_change_request.id }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_approve' do
    subject { get 'confirm_approve', id: cost_change_request.id }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #approve' do
    subject { post 'approve', id: cost_change_request.id }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #reject' do
    subject { post 'reject', id: cost_change_request.id }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #bulk_process' do
    subject { post 'bulk_process', ids: [cost_change_request.id], commit: 'approve' }

    context 'as an admin' do
      before { sign_in create_admin }
      it { is_expected.to be_success }

      context 'without commit param' do
        subject { post 'bulk_process', ids: [cost_change_request.id], format: :json }
        its(:status) { is_expected.to eq(400) }
      end

      context 'with empty ids' do
        subject { post 'bulk_process', ids: [], commit: 'approve' }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { is_expected.not_to be_success }
    end
  end
end
