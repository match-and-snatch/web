RSpec.describe Dashboard::Admin::ProfilesController, type: :controller do
  before { sign_in create(:user, :admin) }

  describe 'GET #index' do
    subject { get :index, params: {q: 'test'} }
    before { update_index }
    it { is_expected.to be_success }
  end

  describe 'PUT #make_public' do
    let(:user) { create :user, :profile_owner }
    subject { put :make_public, params: {id: user.id} }
    its(:status) { is_expected.to eq(200)}
  end

  describe 'PUT #make_private' do
    let(:user) { create :user, :public_profile }
    subject { put :make_private, params: {id: user.id} }
    its(:status) { is_expected.to eq(200)}
  end
end
