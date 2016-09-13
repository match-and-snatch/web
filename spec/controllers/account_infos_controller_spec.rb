RSpec.describe AccountInfosController, type: :controller do
  describe 'GET #show' do
    let(:user) { create(:user) }
    subject(:perform_request) { get 'show' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before do
        sign_in user
        perform_request
      end

      it { expect(assigns('user')).to eq user }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #details' do
    subject(:perform_request) { get 'details' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before do
        sign_in
        perform_request
      end

      it { expect(assigns(:user)).to be_a_kind_of(UserStatsDecorator) }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #settings' do
    subject { get 'settings' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_account_picture' do
    subject { put :update_account_picture, params: {transloadit: profile_picture_data_params.to_json} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /replace/ }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put 'update_general_information' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_slug' do
    subject { put :update_slug, params: {slug: 'anotherSlug'} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /notice/ }
      its(:body) { is_expected.to match_regex /reload/ }
    end
  end

  describe 'PUT #change_password' do
    subject { put 'change_password' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #billing_information' do
    subject { get 'billing_information' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #edit_payment_information' do
    subject { get 'edit_payment_information' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #edit_cc_data' do
    subject { get 'edit_cc_data' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put 'update_cc_data' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #confirm_cc_data_removal' do
    subject { get 'confirm_cc_data_removal' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #delete_cc_data' do
    subject { delete 'delete_cc_data' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #create_profile_page' do
    subject { put 'create_profile_page' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #confirm_profile_page_removal' do
    subject { get 'confirm_profile_page_removal' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #delete_profile_page' do
    subject { put 'delete_profile_page' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #enable_vacation_mode' do
    subject { put :enable_vacation_mode, params: {vacation_message: 'test'} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #disable_vacation_mode' do
    subject { put 'disable_vacation_mode' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #enable_rss' do
    subject { put 'enable_rss' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #disable_rss' do
    subject { put 'disable_rss' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #enable_message_notifications' do
    subject { put 'enable_message_notifications' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #disable_message_notifications' do
    subject { put 'disable_message_notifications' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #enable_downloads' do
    subject { put 'enable_downloads' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #disable_downloads' do
    subject { put 'disable_downloads' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #enable_itunes' do
    subject { put 'enable_itunes' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #disable_itunes' do
    subject { put 'disable_itunes' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #accept_tos' do
    subject { post 'accept_tos' }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #toggle_contributions' do
    subject { put 'toggle_contributions', params: {contributions_enabled: true} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end
end
