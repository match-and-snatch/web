FactoryGirl.define do
  factory :payment do
    association(:user) { FactoryGirl.create :user }
    sequence(:amount) { rand(10_00) }
  end
end
