FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@cp.io" }

  end
end
