require 'spec_helper'

describe FeedEventsManager do
  let(:user) { create(:user) }

  subject(:manager) { described_class.new(user: user, target: post) }

  describe '#create_status_event' do
    let(:post) { create(:status_post) }

    it { expect { manager.create_status_event(message: post.message) }.to create_record(StatusFeedEvent) }
    it { expect(manager.create_status_event(message: post.message).data).to eq({message: post.message}) }
  end

  describe '#create_audio_event' do
    let(:post) { create(:audio_post) }

    it { expect { manager.create_audio_event }.to create_record(AudioFeedEvent) }
    it { expect(manager.create_audio_event.data).to eq({count: 1, label: 'audio'}) }
  end

  describe '#create_photo_event' do
    let(:post) { create(:photo_post) }

    it { expect { manager.create_photo_event }.to create_record(PhotoFeedEvent) }
    it { expect(manager.create_photo_event.data).to eq({count: 1, label: 'photo'}) }
  end

  describe '#create_document_event' do
    let(:post) { create(:document_post) }

    it { expect { manager.create_document_event }.to create_record(DocumentFeedEvent) }
    it { expect(manager.create_document_event.data).to eq({count: 1, label: 'document'}) }
  end

  describe '#create_video_event' do
    let(:post) { create(:video_post) }

    it { expect { manager.create_video_event }.to create_record(VideoFeedEvent) }
  end

  describe 'update_uploads_log' do
    let(:post) { create(:photo_post, photos_count: 2) }
    let!(:event) { manager.create_photo_event }

    before { post.uploads.first.delete }

    it { expect { described_class.new(user: user, target: post).update_uploads_log }.to change { event.reload.data }.from({count: 2, label: 'photos'}).to({count: 1, label: 'photo'})  }
  end

  describe 'turn_to_status_event' do
    let(:post) { create(:video_post) }
    let!(:event) { manager.create_video_event }

    it { expect { described_class.new(user: user, target: post).turn_to_status_event }.to change { FeedEvent.find(event.id).type }.from('VideoFeedEvent').to('StatusFeedEvent') }
    it { expect { described_class.new(user: user, target: post).turn_to_status_event }.to change { FeedEvent.find(event.id).data }.from({}).to({message: /message/}) }
  end
end
