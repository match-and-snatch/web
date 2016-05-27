require 'spec_helper'

describe Dashboard::Admin::RefundsController, type: :controller do
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

    context 'filtered' do
      subject { get 'index', month: Time.now.to_s(:db) }
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end
  end
end
