FactoryGirl.define do
  factory :post do
    association :user, :profile_owner
    sequence(:title) { |n| "title-#{n}" }
    sequence(:message) { |n| "message-#{n}" }
    hidden false
    pinned false
  end

  factory :audio_post, parent: :post, class: AudioPost do
    type 'AudioPost'

    transient { audios_count 1 }

    after(:create) do |post, evaluator|
      create_list(:audio, evaluator.audios_count, uploadable: post)
    end
  end

  factory :photo_post, parent: :post, class: PhotoPost do
    type 'PhotoPost'

    transient { photos_count 1 }

    after(:create) do |post, evaluator|
      create_list(:photo, evaluator.photos_count, uploadable: post)
    end
  end

  factory :document_post, parent: :post, class: DocumentPost do
    type 'DocumentPost'

    transient { documents_count 1 }

    after(:create) do |post, evaluator|
      create_list(:document, evaluator.documents_count, uploadable: post)
    end
  end

  factory :video_post, parent: :post, class: VideoPost do
    type 'VideoPost'

    transient { videos_count 1 }

    after(:create) do |post, evaluator|
      create_list(:video, evaluator.videos_count, uploadable: post)
    end
  end

  factory :status_post, parent: :post, class: StatusPost do
    title nil
    type 'StatusPost'
  end
end
