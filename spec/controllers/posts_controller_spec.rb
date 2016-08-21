require 'spec_helper'

RSpec.describe PostsController, type: :controller do
  let(:poster) { create(:user, :profile_owner) }

  describe 'GET #index' do
    subject { get :index, params: {user_id: poster.slug} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: {user_id: poster.slug, message: 'Reply'}, format: :json }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #show' do
    let(:post) { create(:status_post, user: poster) }

    context 'unauthorized access' do
      subject { get :show, params: {id: post.id} }
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }

      context 'when not audio post' do
        subject { get :show, params: {id: post.id} }
        its(:status) { is_expected.to eq(404) }
      end

      let(:audio_post) { create(:audio_post, user: poster) }

      context 'when requests html' do
        subject { get :show, params: {id: audio_post.id} }
        its(:status) { is_expected.to eq(404) }
      end

      context 'when requests xml' do
        subject { get :show, params: { id: audio_post.id , format: 'xml'} }
        it { is_expected.to be_success }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in poster }
    let(:post) { create(:status_post, user: poster) }

    subject { delete :destroy, params: {id: post.id} }
    it { is_expected.to be_success }

    context 'no post present' do
      subject { delete :destroy, params: {id: 0} }
      its(:status) { is_expected.to eq(404) }
    end

    context 'unauthorized access' do
      let(:another_poster) { create :user, email: 'anther@poster.ru' }
      let(:post) { create(:status_post, user: another_poster) }
      its(:status) { is_expected.to eq(401) }
    end
  end

  describe 'GET #text' do
    let(:post) { create(:status_post, user: poster) }
    subject { get :text, params: {id: post.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #pin' do
    let(:_post) { create(:status_post, user: poster) }
    subject { post :pin, params: {id: _post.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #unpin' do
    let(:_post) { create(:status_post, user: poster) }
    subject { post :unpin, params: {id: _post.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in poster }
      it { is_expected.to be_success }
    end
  end
end
