FactoryGirl.define do
  factory :upload do
    user { FactoryGirl.create :user, :profile_owner }
    uploadable nil
    removed false
    filesize 100
  end

  factory :audio, parent: :upload, class: Audio do
    type 'Audio'
  end

  factory :photo, parent: :upload, class: Photo do
    type 'Photo'
  end

  factory :document, parent: :upload, class: Document do
    type 'Document'
  end

  factory :video, parent: :upload, class: Video do
    type 'Video'
  end
end
