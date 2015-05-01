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

  describe 'DELETE #destroy' do
    before { sign_in_with_token(poster.api_token) }

    let(:post) { PostManager.new(user: poster).create_status_post(message: 'test') }

    subject { delete 'destroy', id: post.id }

    it { should be_success }

    context 'no post present' do
      subject { delete 'destroy', id: 0 }

      its(:status) { should eq(404) }
    end

    context 'unauthorized access' do
      let(:another_poster) { create_user email: 'anther@poster.ru' }
      let(:post) { PostManager.new(user: another_poster).create_status_post(message: 'test') }

      its(:status) { should eq(401) }
    end
  end
end
