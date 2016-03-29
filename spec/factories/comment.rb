FactoryGirl.define do
  factory :comment do
    sequence(:message) { |n| "message-#{n}" }

    association :user
    association :post, factory: :status_post

    hidden false

    trait :reply do
      association :parent, factory: :comment
    end
  end
end
