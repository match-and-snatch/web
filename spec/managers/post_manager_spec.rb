require 'spec_helper'

describe PostManager, freeze: true do
  let(:user) { create_user }
  subject(:manager) { described_class.new(user: user) }

  describe '#create' do
    specify do
      expect(manager.create_status_post(message: 'some text')).to be_a Post
    end

    specify do
      expect(manager.create_status_post(message: 'some text')).to be_persisted
    end

    specify do
      expect { manager.create_status_post(message: 'some text') }.to change { user.reload.last_post_created_at }.from(nil)
    end

    it 'creates status_post_created event' do
      expect { manager.create_status_post(message: 'some text') }.to create_event(:status_post_created)
    end
  end

  describe '#hide' do
    let(:post) { manager.create_status_post(message: 'test') }
    let(:hiding_manager) { described_class.new(user: user, post: post) }

    specify do
      expect { hiding_manager.hide }.to change { user.reload.last_post_created_at }.from(post.created_at).to(nil)
    end
  end

  describe '#show' do
    let(:post) { manager.create_status_post(message: 'test') }
    let(:hiding_manager) { described_class.new(user: user, post: post) }

    before do
      hiding_manager.hide
    end

    specify do
      expect { hiding_manager.show }.to change { user.reload.last_post_created_at }.from(nil).to(post.created_at)
    end
  end

  describe '#update' do
    context 'status post' do
      let(:post) { manager.create_status_post(message: 'test') }

      specify do
        expect { manager.update(title: 'test', message: 'updated') }.to change { post.reload.message }.to('updated')
      end

      specify do
        expect { manager.update(title: 'test', message: 'updated') }.not_to change { post.reload.title }.from(nil)
      end
    end

    context 'photo post' do
      let!(:photo) { UploadManager.new(user).create_pending_photos(transloadit_photo_data_params).first }
      let!(:post) { manager.create_photo_post(title: 'test', message: 'test') }

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

    end
  end

  describe '#update_pending' do
    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_a PendingPost
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword')).to be_persisted
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword').message).to eq('message')
    end

    specify do
      expect(manager.update_pending(message: 'message', keywords: 'keyword').user).to eq(user)
    end

    context 'already created' do
      before do
        manager.update_pending(message: 'message', keywords: 'keyword')
      end

      specify do
        expect { manager.update_pending(message: 'new one') }.to change { user.pending_post.message }.from('message').to('new one')
      end

      specify do
        expect { manager.update_pending(keywords: 'new one') }.to change { user.pending_post.keywords }.from('keyword').to('new one')
      end
    end
  end
end
