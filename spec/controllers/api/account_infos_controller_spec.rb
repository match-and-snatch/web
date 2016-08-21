RSpec.describe Api::AccountInfosController, type: :controller do
  let(:user) { create(:user, email: 'user@gmail.com') }

  describe 'GET #settings' do
    subject { get :settings, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'GET #billing_information' do
    subject { get :billing_information, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_account_picture' do
    subject { put :update_account_picture, params: {transloadit: profile_picture_data_params.to_json}, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put :update_general_information, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put :update_cc_data, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #delete_cc_data' do
    subject { delete :delete_cc_data, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #accept_tos' do
    subject { post :accept_tos, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
    end
  end
end
