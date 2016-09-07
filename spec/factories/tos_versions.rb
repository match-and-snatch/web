FactoryGirl.define do
  factory :tos_version do
    sequence(:tos) { |n| "ToS v.#{n}" }
    sequence(:privacy_policy) { |n| "PP v.#{n}" }

    trait :published do
      published_at Time.zone.now
      active true
    end
  end
end
