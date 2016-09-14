RSpec.describe Api::SessionsController, type: :controller do
  describe 'POST #create' do
    subject { post :create, params: {email: user.email, password: 'password'}, format: :json }

    let(:user) { create(:user, email: 'szinin@gmail.com') }

    it { is_expected.to be_success }
    its(:body) { is_expected.to match_regex /"api_token":"#{user.api_token}"/ }

    context 'token set' do
      let!(:user) { create(:user, email: 'szinin@gmail.com', api_token: 'tokenset') }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /"api_token":"tokenset"/ }
    end
  end
end
