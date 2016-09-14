describe Dashboard::Admin::CostChangeRequestsController, type: :controller do
  let(:user) { create(:user, :profile_owner, email: 'profile@mail.com') }
  let(:cost_change_request) { CostChangeRequest.create!(user: user, old_cost: user.cost, new_cost: 800) }

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

  describe 'GET #confirm_reject' do
    subject { get :confirm_reject, params: {id: cost_change_request.id} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_approve' do
    subject { get :confirm_approve, params: {id: cost_change_request.id} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #approve' do
    subject { post :approve, params: {id: cost_change_request.id} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #reject' do
    subject { post :reject, params: {id: cost_change_request.id} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #bulk_process' do
    subject { post :bulk_process, params: {ids: [cost_change_request.id], commit: 'approve'} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { is_expected.to be_success }

      context 'without commit param' do
        subject { post :bulk_process, params: {ids: [cost_change_request.id]}, format: :json }
        its(:status) { is_expected.to eq(400) }
      end

      context 'with empty ids' do
        subject { post :bulk_process, params: {ids: [], commit: 'approve'} }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { is_expected.not_to be_success }
    end
  end
end
