RSpec.describe Dashboard::Admin::MatureProfilesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe 'GET #index' do
    subject { get 'index' }

    context 'as admin' do
      before { sign_in admin }
      it { is_expected.to be_success }

      context 'filtered' do
        subject { get :index, params: {filter: 'welcome_media_hidden'} }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_hide_welcome_media' do
    subject { get :confirm_hide_welcome_media, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'PUT #hide_welcome_media' do
    subject { put :hide_welcome_media, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_show_welcome_media' do
    subject { get :confirm_show_welcome_media, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end


  describe 'PUT #show_welcome_media' do
    subject { put :show_welcome_media, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_hide_benefits' do
    subject { get :confirm_hide_benefits, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'PUT #hide_benefits' do
    subject { put :hide_benefits, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'GET #confirm_show_benefits' do
    subject { get :confirm_show_benefits, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end


  describe 'PUT #show_benefits' do
    subject { put :show_benefits, params: {id: user.id} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end

  describe 'POST #bulk_processing' do
    subject { post :bulk_processing, params: {ids: [user.id], commit: 'hide_welcome_media'} }

    context 'as an admin' do
      before { sign_in admin }
      it { is_expected.to be_success }

      context 'without commit param' do
        subject { post :bulk_processing, params: {ids: [user.id]}, format: :json }
        its(:status) { is_expected.to eq(400) }
      end

      context 'with empty ids' do
        subject { post :bulk_processing, params: {ids: [], commit: 'hide_welcome_media'} }
        it { is_expected.to be_success }
      end
    end

    context 'as a non admin' do
      before { sign_in user }
      it { is_expected.not_to be_success }
    end
  end
end
