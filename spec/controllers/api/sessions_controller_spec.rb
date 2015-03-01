require 'spec_helper'

describe Api::SessionsController, type: :controller do
  describe 'POST #create' do
    subject { post 'create', email: user.email, password: 'password' }

    let!(:user) do
      create_user(email: 'szinin@gmail.com', password: 'password')
    end

    it { should be_success }
    its(:body) { should match_regex /"api_token":"[^-]+"/ }

    context 'token set' do
      let!(:user) do
        create_user(email: 'szinin@gmail.com', password: 'password', api_token: 'tokenset')
      end

      it { should be_success }
      its(:body) { should match_regex /"api_token":"tokenset"/ }
    end
  end
end
