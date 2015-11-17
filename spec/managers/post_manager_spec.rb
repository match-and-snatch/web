require 'spec_helper'

describe PostManager, freeze: true do
  let(:user) { create(:user, :profile_owner) }
  let(:post) { create(:status_post, user: user, message: 'test') }

  subject(:manager) { described_class.new(user: user, post: post) }

  describe '#create_status_post' do
    subject(:manager) { described_class.new(user: user) }

    it { expect(manager.create_status_post(message: 'some text')).to be_a(Post) }
    it { expect(manager.create_status_post(message: 'some text')).to be_persisted }
    it { expect { manager.create_status_post(message: 'some text') }.to change { user.reload.last_post_created_at }.from(nil) }
    it 'creates status_post_created event' do
      expect { manager.create_status_post(message: 'some text') }.to create_event(:status_post_created)
    end
  end

  describe '#hide' do
    before { user.denormalize_last_post_created_at!(post.created_at) }

    it { expect { manager.hide }.to change { user.last_post_created_at }.from(post.created_at).to(nil) }
    it 'indexes post' do
      expect { manager.hide }.to index_record(post).using_index('posts')
    end
  end

  describe '#show' do
    before { manager.hide }

    it { expect { manager.show }.to change { user.last_post_created_at }.from(nil).to(post.created_at) }
    it 'indexes post' do
      expect { manager.hide }.to index_record(post).using_index('posts')
    end
  end

  describe '#update' do
    context 'status post' do
      it { expect { manager.update(title: 'test', message: 'updated') }.to change { post.reload.message }.to('updated') }
      it { expect { manager.update(title: 'test', message: 'updated') }.not_to change { post.reload.title }.from(nil) }
      it 'indexes post' do
        expect { manager.update(title: 'test', message: 'updated') }.to index_record(post).using_index('posts')
      end
    end

    context 'photo post' do
      let!(:photo) { UploadManager.new(user).create_pending_photos(transloadit_photo_data_params).first }
      let!(:post) { manager.create_photo_post(title: 'test', message: 'test') }

      subject(:manager) { described_class.new(user: user) }

      it { expect { manager.update(title: 'updated', message: 'updated') }.to change { post.reload.title }.to('updated') }
      it { expect { manager.update(title: 'updated', message: 'updated') }.to change { post.reload.message }.to('updated') }

      it { expect { manager.update(title: 'updated', message: 'updated') }.not_to delete_record(Photo) }
      it { expect { manager.update(title: 'updated', message: 'updated', upload_ids: 123) }.not_to delete_record(Photo) }

      it 'does not delete specified photo' do
        expect { manager.update(title: 'updated', message: 'updated', upload_ids: [photo]) }.not_to delete_record(Photo).matching(id: photo.id)
      end

      it 'delete all photos' do
        expect { manager.update(title: 'updated', message: 'updated', upload_ids: []) }.to delete_record(Photo).matching(id: photo.id)
      end

      it 'indexes post' do
        expect { manager.update(title: 'updated', message: 'updated') }.to index_record(post).using_index('posts')
      end
    end
  end

  describe '#update_pending' do
    subject(:manager) { described_class.new(user: user) }

    it { expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_a(PendingPost) }
    it { expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_persisted }
    it { expect(manager.update_pending(message: 'message', keywords: 'keyword').message).to eq('message') }
    it { expect(manager.update_pending(message: 'message', keywords: 'keyword').user).to eq(user) }

    context 'already created' do
      before { manager.update_pending(message: 'message', keywords: 'keyword') }

      it { expect { manager.update_pending(message: 'new one') }.to change { user.pending_post.message }.from('message').to('new one') }
      it { expect { manager.update_pending(keywords: 'new one') }.to change { user.pending_post.keywords }.from('keyword').to('new one') }
    end
  end

  describe '#delete' do
    let(:another_post) { create(:status_post, user: user, message: 'another test') }

    before { update_index another_post }

    it { expect { manager.delete(another_post) }.to delete_record(StatusPost) }
    it { expect { manager.delete(another_post) }.to delete_record_index_document(another_post).from_index('posts') }
  end
end
