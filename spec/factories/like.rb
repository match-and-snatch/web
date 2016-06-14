FactoryGirl.define do
  factory :like do
    association :user
    association :target_user, factory: :user
  end

  factory :like_for_comment, parent: :like do
    association :likable, factory: :comment
    association :comment
  end

  factory :like_for_post, parent: :like do
    association :likable, factory: :status_post
    association :post, factory: :status_post
  end
end
