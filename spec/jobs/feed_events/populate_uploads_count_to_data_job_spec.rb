require 'spec_helper'

describe FeedEvents::PopulateUploadsCountToDataJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create(:user, :profile_owner) }

    let(:audio_event) { AudioFeedEvent.create!(subscription_target_user: user, target: create(:audio_post)) }
    let(:photo_event) { PhotoFeedEvent.create!(subscription_target_user: user, target: create(:audio_post)) }
    let(:document_event) { DocumentFeedEvent.create!(subscription_target_user: user, target: create(:document_post)) }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to change { audio_event.reload.data }.from({}).to({count: 1, label: 'audio'}) }
    it { expect { perform }.to change { photo_event.reload.data }.from({}).to({count: 1, label: 'photo'}) }
    it { expect { perform }.to change { document_event.reload.data }.from({}).to({count: 1, label: 'document'}) }

    context 'existing data' do
      let(:audio_event) { FeedEventsManager.new(user: user, target: create(:audio_post)).create_audio_event }

      it { expect { perform }.not_to change { audio_event.reload.data }.from({count: 1, label: 'audio'}) }
    end
  end
end
