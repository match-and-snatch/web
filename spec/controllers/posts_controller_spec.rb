require 'spec_helper'

describe PostsController do
  let(:poster) { create_user email: 'poster@gmail.com', is_profile_owner: true }

  describe 'GET #index' do
    subject { get 'index', user_id: poster.slug }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in poster }
      its(:status) { should == 200 }
    end
  end

  describe 'POST #create' do
    subject { post 'create', user_id: poster.slug, message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in poster }
      its(:status) { should == 200 }
    end
  end
end