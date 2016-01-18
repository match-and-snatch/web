FactoryGirl.define do
  factory :cost_change_request do
    old_cost nil
    new_cost 5_00
    user { FactoryGirl.create :user }

    trait :pending do
      approved false
      rejected false
      performed false
    end

    trait :approved do
      approved true
      rejected false
      performed false
    end

    trait :rejected do
      approved false
      rejected true
      performed false
    end

    trait :performed do
      performed true
    end
  end
end

