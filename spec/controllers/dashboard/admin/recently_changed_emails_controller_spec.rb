require 'spec_helper'

describe Dashboard::Admin::RecentlyChangedEmailsController, type: :controller do
  let(:user) { create(:user, old_email: 'old_email@mail.com', email_updated_at: Time.zone.now) }

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
      subject { get :index, params: {filter: 'previous_month'} }
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end
  end
end
