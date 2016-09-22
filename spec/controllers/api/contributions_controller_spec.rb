describe Api::ContributionsController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, :profile_owner) }
  let(:contribution) { create(:contribution, target_user: target_user, user: user) }

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: {id: contribution.id}, format: :json }

    context 'authorized access' do
      before { sign_in_with_token(user.api_token) }
      it { is_expected.to be_success }
    end
  end
end
