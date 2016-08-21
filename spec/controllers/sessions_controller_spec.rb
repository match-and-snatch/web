RSpec.describe SessionsController, type: :controller do
  describe 'GET #logout' do
    subject { get 'logout' }
    it { is_expected.to be_redirect }
  end

  describe 'POST #create' do
    subject { post :create, params: {email: 'szinin@gmail.com', password: 'password'} }

    it { is_expected.to be_success }
    its(:body) { is_expected.to match_regex /failed/ }

    context 'registered user' do
      before { create(:user, email: 'szinin@gmail.com') }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /reload/ }
    end
  end
end
