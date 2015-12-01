FactoryGirl.define do
  factory :subscription do
    notifications_enabled true
    charged_at { Time.zone.now }
    removed false
    rejected false
    cost 500
    fees 99
    total_cost 599

    before(:create) do |subscription|
      unless subscription.target_id
        subscription.target = subscription.target_user
      end
    end
  end
end