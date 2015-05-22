require 'spec_helper'

describe Api::PostsController, type: :controller do
  let(:poster) { create_profile email: 'poster@gmail.com', api_token: 'test_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'GET #index' do
    subject { get 'index', user_id: poster.slug }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { should be_success }
    end
  end

  describe 'GET #show' do
    subject { get 'show', id: _post.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { should be_success }
    end
  end

  describe 'POST #create' do
    subject { post 'create', user_id: poster.slug, message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { should be_success }
    end
  end
end
