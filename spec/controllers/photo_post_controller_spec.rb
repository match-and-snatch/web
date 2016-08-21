describe PhotoPostsController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'DELETE #cancel' do
    subject { delete :cancel }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /success/ }
    end
  end

  describe 'GET #new' do
    subject { get :new, format: :json }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: {title: 'aa', message: 'bb'}, format: :json }

    context 'authorized access' do
      before { sign_in owner }
      let!(:pending_photo) { create(:photo, :pending, user: owner) }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end
  end
end
