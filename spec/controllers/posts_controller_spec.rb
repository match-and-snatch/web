require 'spec_helper'

describe PostsController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com', is_profile_owner: true }

  describe 'GET #index' do
    subject { get 'index', user_id: poster.slug }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { should be_success }
    end
  end

  describe 'POST #create' do
    subject { post 'create', user_id: poster.slug, message: 'Reply' }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { should be_success }
    end
  end

  describe 'GET #show' do
    let(:post) { PostManager.new(user: poster).create_status_post(message: 'test') }

    context 'when not audio post' do
      subject { get 'show', id: post.id}
      its(:status) { should == 404 }
    end

    let(:audio_post) do
      create_audio_upload poster
      PostManager.new(user: poster).create_audio_post(message: 'test', title: 'test')
    end

    context 'when requests html' do
      subject { get 'show', id: audio_post.id }
      its(:status) { should == 404 }
    end

    context 'when requests xml' do
      subject { get 'show',  id: audio_post.id , format: 'xml' }
      it { should be_success }
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in poster }
    let(:post) { PostManager.new(user: poster).create_status_post(message: 'test') }

    subject { delete 'destroy', id: post.id }
    it { should be_success }

    context 'no post present' do
      subject { delete 'destroy', id: 0 }
      its(:status) { should == 404 }
    end

    context 'unauthorized access' do
      let(:another_poster) { create_user email: 'anther@poster.ru' }
      let(:post) { PostManager.new(user: another_poster).create_status_post(message: 'test') }
      its(:status) { should == 401 }
    end
  end
end
