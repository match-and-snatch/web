require 'spec_helper'

describe SessionsController, type: :controller do
  describe 'GET #logout' do
    subject { get 'logout' }
    it { should be_redirect }
  end

  describe 'POST #create' do
    subject { post 'create', email: 'szinin@gmail.com', password: 'password' }

    it { should be_success }
    its(:body) { should match_regex /failed/ }

    context 'registered user' do
      before { create(:user, email: 'szinin@gmail.com') }

      it { should be_success }
      its(:body) { should match_regex /reload/ }
    end
  end
end
