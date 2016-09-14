describe ProfileTypesController, type: :controller do
  before { sign_in }

  describe 'GET #index' do
    subject { get :index, params: {q: 'test'} }
    it { is_expected.to be_success }
  end

  describe 'POST #create' do
    context 'profile type does not exist' do
      subject { post :create, params: {type: 'test'} }
      it { is_expected.to be_success }
    end

    context 'profile type does exist' do
      subject { post :create, params: {type: 'test'} }
      before { ProfileTypeManager.new.create(title: 'test') }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    context 'profile type does not exist' do
      subject { delete :destroy, params: {id: 1} }
      it { is_expected.not_to be_success }
    end

    context 'profile type does exist' do
      subject { delete :destroy, params: {id: profile_type.id} }
      let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #reorder' do
    subject { post :reorder, params: {ids: [1, 2, 3]} }
    its(:status) { is_expected.to eq(200) }
  end
end
