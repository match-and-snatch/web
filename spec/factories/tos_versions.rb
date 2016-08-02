FactoryGirl.define do
  factory :tos_version do
    sequence(:tos) { |n| "ToS v.#{n}" }

    trait :published do
      published_at Time.zone.now
    end
  end
end
