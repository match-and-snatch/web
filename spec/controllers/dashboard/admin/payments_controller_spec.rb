require 'spec_helper'

describe Dashboard::Admin::PaymentsController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #pending' do
    subject { get 'pending', user_id: create(:user).id }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }

      context 'with date' do
        subject { get 'pending', user_id: create(:user).id, date: Time.zone.now.to_i }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #addresses' do
    subject { get 'addresses', user_id: create(:user).id }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end
end
