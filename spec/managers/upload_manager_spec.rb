require 'spec_helper'

describe UploadManager do
  let(:user) { create(:user, :profile_owner) }

  subject { described_class.new(user) }

  describe '#create_pending_photos' do
    let(:photos) { subject.create_pending_photos(ActionController::ManagebleParameters.new(transloadit_photo_data_params)) }

    it { expect(photos.first.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_pending_documents' do
    let(:documents) { subject.create_pending_documents(ActionController::ManagebleParameters.new(transloadit_document_data_params)) }

    it { expect(documents.first.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_photo' do
    let(:photo) { subject.create_photo(ActionController::ManagebleParameters.new(profile_picture_data_params), template: 'profile_picture') }

    it { expect(photo.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_video' do
    let(:video) { subject.create_video(ActionController::ManagebleParameters.new(transloadit_video_data_params)) }

    it { expect(video.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_audio' do
    let(:audios) { subject.create_audio(ActionController::ManagebleParameters.new(transloadit_audio_data_params)) }

    it { expect(audios.first.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_welcome_media' do
    context 'passes video file' do
      it { expect(subject.create_welcome_media(transloadit_video_data_params)).to be_a(Video) }
    end

    context 'passes audio file' do
      it { expect(subject.create_welcome_media(transloadit_audio_data_params)).to be_a(Audio) }
    end
  end
end
