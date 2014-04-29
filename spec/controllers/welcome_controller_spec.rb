require 'spec_helper'

describe WelcomeController do
  describe 'GET #show' do
    subject(:perform_request) { get 'show' }

    context 'when authorized' do
      before { sign_in user }
      before { perform_request }

      context 'when has profile' do
        let(:user) { create_profile }
        it{ response.should redirect_to profile_path(user) }
      end

      context 'when has no profile' do
        let(:user) { create_user }
        it{ response.should redirect_to account_info_path }
      end
    end

    context 'when not authorized' do
      it { should be_success }
    end
  end
end