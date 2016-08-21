describe Dashboard::Sales::UsersController, type: :controller do
  before { sign_in create(:user, :sales) }

  describe 'POST #login_as' do
    let(:user) { create(:user, email: 'another@gmail.com') }

    subject { post :login_as, params: {id: user.id} }

    its(:body) { is_expected.to match_regex 'redirect'}
    its(:status) { is_expected.to eq(200) }
  end
end
