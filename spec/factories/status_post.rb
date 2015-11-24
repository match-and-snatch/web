FactoryGirl.define do
  factory :status_post do
    association :user, :profile_owner
    title nil
    sequence(:message) { |n| "message-#{n}" }
    hidden false
    type 'StatusPost'
  end
end
