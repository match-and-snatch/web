require 'spec_helper'

describe Api::PostsController, type: :controller do
  let(:poster) { create_profile email: 'poster@gmail.com', api_token: 'test_token' }
  let(:another_poster) { create_user email: 'anther@poster.ru' }
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

  describe 'DELETE #destroy' do
    before { sign_in_with_token(poster.api_token) }

    subject { delete 'destroy', id: _post.id }

    it { should be_success }

    context 'no post present' do
      subject { delete 'destroy', id: 0 }

      its(:status) { should eq(404) }
    end

    context 'unauthorized access' do
      let(:_post) { PostManager.new(user: another_poster).create_status_post(message: 'test') }

      its(:status) { should eq(401) }
    end
  end

  describe 'PATCH #update' do
    before { sign_in_with_token(poster.api_token) }
    subject(:perform_request) { patch 'update', id: _post.id, title: 'new title', message: 'new message' }

    it { should be_success }

    context 'media post' do
      let(:_post) do
        create_audio_upload poster
        PostManager.new(user: poster).create_audio_post(message: 'test', title: 'test')
      end

      it { should be_success }
      specify do
        expect { perform_request }.not_to change { _post.uploads.count }
      end

      context 'removes upload' do
        subject(:perform_request) { patch 'update', id: _post.id, title: 'new title', message: 'new message', uploads: [_post.uploads.first.id] }

        it { should be_success }
        specify do
          expect { perform_request }.to change { _post.uploads.count }.by(-1)
        end
      end

      context 'removes all uploads' do
        subject(:perform_request) { patch 'update', id: _post.id, title: 'new title', message: 'new message', uploads: [] }

        it { should be_success }
        specify do
          expect { perform_request }.to change { _post.uploads.count }.to(0)
        end

        context 'with 0 as id' do
          subject(:perform_request) { patch 'update', id: _post.id, title: 'new title', message: 'new message', uploads: [0] }

          specify do
            expect { perform_request }.to change { _post.uploads.count }.to(0)
          end
        end
      end

      context 'does not remove uploads' do
        subject(:perform_request) { patch 'update', id: _post.id, title: 'new title', message: 'new message', uploads: _post.uploads.map(&:id) }

        it { should be_success }
        specify do
          expect { perform_request }.not_to change { _post.uploads.count }
        end
      end
    end

    context 'unauthorized access' do
      let(:_post) { PostManager.new(user: another_poster).create_status_post(message: 'test') }

      its(:status) { should eq(401) }
    end
  end
end
