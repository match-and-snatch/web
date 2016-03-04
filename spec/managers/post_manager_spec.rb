require 'spec_helper'

describe PostManager, freeze: true do
  let(:user) { create(:user, :profile_owner) }
  let(:post) { create(:status_post, user: user, message: 'test') }

  subject(:manager) { described_class.new(user: user, post: post) }

  describe '#create_status_post' do
    subject { described_class.new(user: user).create_status_post(message: 'some text') }

    it { expect(subject).to be_persisted }

    it { expect { subject }.to create_record(Post).matching(message: 'some text', user: user) }
    it { expect { subject }.to change { user.reload.last_post_created_at }.from(nil) }
    it 'creates status_post_created event' do
      expect { subject }.to create_event(:status_post_created)
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
      subject { manager.update(title: 'test', message: 'updated') }

      it { expect { subject }.to change { post.reload.message }.to('updated') }
      it { expect { subject }.not_to change { post.reload.title }.from(nil) }
      it 'indexes post' do
        expect { subject }.to index_record(post).using_index('posts')
      end
    end

    context 'photo post' do
      let!(:photo) { UploadManager.new(user).create_pending_photos(transloadit_photo_data_params).first }
      let!(:post) { manager.create_photo_post(title: 'test', message: 'test') }
      let(:update_params) { { title: 'updated', message: 'updated' } }

      subject(:manager) { described_class.new(user: user) }

      it { expect { manager.update(update_params) }.to change { post.reload.title }.to('updated') }
      it { expect { manager.update(update_params) }.to change { post.reload.message }.to('updated') }

      it { expect { manager.update(update_params) }.not_to delete_record(Photo) }
      it { expect { manager.update(update_params.merge(upload_ids: 123)) }.not_to delete_record(Photo) }

      it 'does not delete specified photo' do
        expect { manager.update(update_params.merge(upload_ids: [photo])) }.not_to delete_record(Photo).matching(id: photo.id)
      end

      it 'delete all photos' do
        expect { manager.update(update_params.merge(upload_ids: [])) }.to delete_record(Photo).matching(id: photo.id)
      end

      it 'indexes post' do
        expect { manager.update(update_params) }.to index_record(post).using_index('posts')
      end
    end
  end

  describe '#update_pending' do
    let(:update_params) { { message: 'message', keywords: 'keyword' } }

    subject(:manager) { described_class.new(user: user) }

    it { expect(manager.update_pending(update_params)).to be_persisted }

    it { expect { manager.update_pending(update_params) }.to create_record(PendingPost).matching(message: 'message', keywords: 'keyword', user: user) }

    context 'already created' do
      before { manager.update_pending(update_params) }

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

  describe '#turn_to_status_post' do
    it { expect { manager.turn_to_status_post }.to raise_error(ManagerError, /Post already is StatusPost/) }

    context 'not a status post' do
      let(:post) { create(:photo_post, user: user, message: 'test') }

      it { expect { manager.turn_to_status_post }.not_to change { post.type }.from('PhotoPost') }

      context 'without uploads' do
        let!(:event) { FeedEventsManager.new(user: user, target: post).create_photo_event }

        before { post.uploads.destroy_all }

        it { expect { manager.turn_to_status_post }.to change { post.type }.from('PhotoPost').to('StatusPost') }
        it { expect { manager.turn_to_status_post }.to change { post.title }.from(/title/).to(nil) }

        it 'turns photo event to status event' do
          expect { manager.turn_to_status_post }.to change { FeedEvent.find(event.id).type }.from('PhotoFeedEvent').to('StatusFeedEvent')
        end
        it 'logs message to event' do
          expect { manager.turn_to_status_post }.to change { FeedEvent.find(event.id).data }.from({count: 1, label: 'photo'}).to({message: 'test'})
        end
      end
    end
  end
end
