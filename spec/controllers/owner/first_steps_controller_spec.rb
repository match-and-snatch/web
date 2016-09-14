describe Owner::FirstStepsController, type: :controller do
  describe 'GET #show' do
    subject(:perform_request) { get 'show' }

    context 'authorized' do
      let(:user) { create(:user) }
      before { sign_in user }
      it { is_expected.to be_success }

      context 'already have profile created' do
        pending 'redirects me to my profile page'
      end
    end

    context 'unauthorized' do
      its(:status) { is_expected.to eq(401) }
    end
  end
end
