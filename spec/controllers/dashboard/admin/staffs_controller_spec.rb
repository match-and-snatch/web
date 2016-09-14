describe Dashboard::Admin::StaffsController, type: :controller do
  before { sign_in create(:user, :admin) }

  describe 'GET #index' do
    subject { get 'index' }
    it { is_expected.to be_success }
  end
end
