FactoryGirl.define do
  factory :upload do
    user { FactoryGirl.create :user, :profile_owner }
    uploadable nil
    removed false
    filesize 100

    trait :pending do
      uploadable_id nil
      uploadable_type 'Post'
    end
  end

  factory :audio, parent: :upload, class: Audio do
    type 'Audio'
    uploadable { FactoryGirl.create :audio_post, audios_count: 0 }
  end

  factory :photo, parent: :upload, class: Photo do
    type 'Photo'
    uploadable { FactoryGirl.create :photo_post, photos_count: 0 }
  end

  factory :document, parent: :upload, class: Document do
    type 'Document'
    uploadable { FactoryGirl.create :document_post, documents_count: 0 }
  end

  factory :video, parent: :upload, class: Video do
    type 'Video'
    uploadable { FactoryGirl.create :video_post, videos_count: 0 }
  end
end
