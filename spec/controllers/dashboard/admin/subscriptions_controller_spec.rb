RSpec.describe Dashboard::Admin::SubscriptionsController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:owner) { create(:user, :profile_owner) }
  let(:subscription) { create(:subscription, user: user, target_user: owner) }

  describe 'GET #search' do
    subject { get :search, params: {format: :json, q: 'andy'} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

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

    context 'filtered' do
      subject { get :index, params: {filter: {user_id: 123}} }
      before { sign_in admin }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #confirm_deletion' do
    subject { get :confirm_deletion, params: {id: subscription.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'PUT #delete' do
    subject { put :delete, params: {id: subscription.id} }

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
