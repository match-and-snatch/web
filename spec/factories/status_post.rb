FactoryGirl.define do
  factory :status_post do
    association :user, :profile_owner
    sequence(:message) { |n| "message-#{n}" }
    hidden false
    type 'StatusPost'
  end
end
