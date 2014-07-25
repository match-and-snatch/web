require 'spec_helper'

describe WelcomeController, type: :controller do
  describe 'GET #show' do
    subject(:perform_request) { get 'show' }

    context 'when authorized' do
      before { sign_in user }
      before { perform_request }

      context 'when has profile' do
        let(:user) { create_profile }

        specify do
          expect(response).to redirect_to profile_path(user)
        end
      end

      context 'when has no profile' do
        let(:user) { create_user }

        specify do
          expect(response).to redirect_to account_info_path
        end
      end
    end

    context 'when not authorized' do
      it { should be_success }
    end
  end
end
