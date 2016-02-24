require 'spec_helper'

describe FeedEventsManager do
  let(:user) { create(:user) }

  subject(:manager) { described_class.new(user: user, target: post) }

  context 'status post' do
    let(:post) { create(:status_post) }

    it { expect { manager.create_status_event(message: post.message) }.to create_record(StatusFeedEvent) }
    it { expect(manager.create_status_event(message: post.message).data).to eq({message: post.message}) }
  end

  context 'audio post' do
    let(:post) { create(:audio_post) }

    it { expect { manager.create_audio_event }.to create_record(AudioFeedEvent) }
    it { expect(manager.create_audio_event.data).to eq({count: 1, label: 'audio'}) }
  end

  context 'photo post' do
    let(:post) { create(:photo_post) }

    it { expect { manager.create_photo_event }.to create_record(PhotoFeedEvent) }
    it { expect(manager.create_photo_event.data).to eq({count: 1, label: 'photo'}) }
  end

  context 'document post' do
    let(:post) { create(:document_post) }

    it { expect { manager.create_document_event }.to create_record(DocumentFeedEvent) }
    it { expect(manager.create_document_event.data).to eq({count: 1, label: 'document'}) }
  end

  context 'video post' do
    let(:post) { create(:video_post) }

    it { expect { manager.create_video_event }.to create_record(VideoFeedEvent) }
  end
end
