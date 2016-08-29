FactoryGirl.define do
  factory :contribution do
    amount 100
    user { FactoryGirl.create(:user, :with_cc) }
    target_user { FactoryGirl.create(:user, :profile_owner, subscribers_count: 5, contributions_enabled: true) }
    recurring false
    cancelled false

    trait :cancelled do
      cancelled true
      cancelled_at Time.zone.now
    end
  end
end
