describe Api::ContributionsController, type: :controller do
  let(:user) { create(:user, :with_cc) }
  let(:target_user) { create(:user, :profile_owner) }
  let(:contribution) { create(:contribution, target_user: target_user, user: user, recurring: true) }

  describe 'POST #create' do
    subject { post :create, params: {target_user_id: target_user.slug, amount: 10_00, recurring: false}, format: :json }

    before do
      StripeMock.start
      SubscriptionManager.new(subscriber: user).subscribe_to(target_user)
      4.times do
        SubscriptionManager.new(subscriber: create(:user)).subscribe_to(target_user)
      end
    end
    after { StripeMock.stop }

    context 'authorized access' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
      it { expect(JSON.parse(subject.body)).to include({'status'=>'success'}) }
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: {id: contribution.id}, format: :json }

    context 'authorized access' do
      before { sign_in_with_token(user.api_token) }

      it { is_expected.to be_success }
      it { expect(JSON.parse(subject.body)).to include({'status'=>'success'}) }
    end
  end
end
