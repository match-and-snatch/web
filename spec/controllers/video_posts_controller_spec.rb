describe VideoPostsController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'DELETE #cancel' do
    let!(:pending_video) { create(:video, user: owner) }
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

    before { create(:video, :pending, user: owner) }

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end
  end
end
