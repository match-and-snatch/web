require 'spec_helper'

describe Dashboard::Sales::UsersController, type: :controller do
  before { sign_in create_sales }

  describe 'POST #login_as' do
    let(:user) { create_user(email: 'another@gmail.com') }

    subject { post 'login_as', id: user.id }

    its(:body) { should match_regex 'redirect'}
    its(:status) { should eq(200) }
  end
end