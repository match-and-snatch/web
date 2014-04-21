require 'spec_helper'

describe UsersController do
  describe 'POST #create' do
    context 'nothing passed' do
      subject { post 'create' }

      it { should be_success }
      its(:body) { should match_regex /failed/ }
    end

    context 'proper params' do
      subject { post 'create', email: 'szinin@gmail.com',
                               first_name: 'sergei',
                               last_name: 'zinin',
                               password: 'qwerty',
                               password_confirmation: 'qwerty' }

      it { should be_success }
      its(:body) { should match_regex /redirect/ }
    end
  end
end