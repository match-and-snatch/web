require 'spec_helper'

describe Api::PostsController, type: :controller do
  let(:poster) { create(:user, :profile_owner, email: 'poster@gmail.com') }
  let(:another_poster) { create(:user, email: 'anther@poster.ru') }
  let(:_post) { create(:status_post, message: 'some post', user: poster) }

  describe 'GET #index' do
    subject { get :index, params: {user_id: poster.slug}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'GET #show' do
    subject { get :show, params: {id: _post.id}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in_with_token(poster.api_token) }

    subject { delete :destroy, params: {id: _post.id}, format: :json }

    it { is_expected.to be_success }

    context 'no post present' do
      subject { delete :destroy, params: {id: 0}, format: :json }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
    end

    context 'unauthorized access' do
      let(:_post) { create(:status_post, user: another_poster) }

      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end

  describe 'PATCH #update' do
    before { sign_in_with_token(poster.api_token) }
    subject(:perform_request) { patch :update, params: {id: _post.id, title: 'new title', message: 'new message'}, format: :json }

    it { is_expected.to be_success }

    context 'media post' do
      let(:_post) { create(:audio_post, user: poster, message: 'test', title: 'test', audios_count: 2) }

      it { is_expected.to be_success }
      it { expect { perform_request }.not_to change { _post.uploads.count } }

      context 'removes upload' do
        subject(:perform_request) { patch :update, params: {id: _post.id, title: 'new title', message: 'new message', uploads: [_post.uploads.first.id]}, format: :json }

        it { is_expected.to be_success }
        it { expect { perform_request }.to change { _post.uploads.count }.by(-1) }
      end

      context 'removes all uploads' do
        subject(:perform_request) { patch :update, params: {id: _post.id, title: 'new title', message: 'new message', uploads: []}, format: :json }

        it { is_expected.to be_success }
        it { expect { perform_request }.to change { _post.uploads.reload.count }.to(0) }

        context 'with 0 as id' do
          subject(:perform_request) { patch :update, params: {id: _post.id, title: 'new title', message: 'new message', uploads: [0]}, format: :json }

          it { expect { perform_request }.to change { _post.uploads.count }.to(0) }
        end
      end

      context 'does not remove uploads' do
        subject(:perform_request) { patch :update, params: {id: _post.id, title: 'new title', message: 'new message', uploads: _post.uploads.map(&:id)}, format: :json }

        it { is_expected.to be_success }
        it { expect { perform_request }.not_to change { _post.uploads.count } }
      end
    end

    context 'unauthorized access' do
      let(:_post) { create(:status_post, user: another_poster) }

      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end

  describe 'POST #pin' do
    subject { post :pin, params: {id: _post.id}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #unpin' do
    subject { post :unpin, params: {id: _post.id}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(poster.api_token) }

      it { is_expected.to be_success }
    end
  end
end
