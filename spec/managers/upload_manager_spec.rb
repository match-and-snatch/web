require 'spec_helper'

describe UploadManager do
  let(:user) { create_profile }

  subject { described_class.new(user) }

  describe '#create_pending_photos' do
    let(:photos) { subject.create_pending_photos(ActionController::ManagebleParameters.new(transloadit_photo_data_params)) }

    it { expect(photos.first.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_pending_documents' do
    let(:documents) { subject.create_pending_documents(ActionController::ManagebleParameters.new(JSON.parse(transloadit_document_data_params['transloadit']))) }

    it { expect(documents.first.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_photo' do
    let(:photo) { subject.create_photo(ActionController::ManagebleParameters.new(JSON.parse(profile_picture_data_params['transloadit'])), template: 'profile_picture') }

    it { expect(photo.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_video' do
    let(:video) { subject.create_video(ActionController::ManagebleParameters.new(transloadit_video_data_params)) }

    it { expect(video.transloadit_data.class).to eq(Hash) }
  end

  describe '#create_audio' do
    let(:audios) { subject.create_audio(ActionController::ManagebleParameters.new(JSON.parse(transloadit_audio_data_params['transloadit']))) }

    it { expect(audios.first.transloadit_data.class).to eq(Hash) }
  end
end
