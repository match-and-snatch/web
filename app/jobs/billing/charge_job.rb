module Billing
  class ChargeJob
    def self.perform
      Subscription.to_charge.find_each do |subscription|
        p "Paying for #{subscription.id}" unless Rails.env.test?
        PaymentManager.new.pay_for(subscription) if subscription.user
      end
    end
  end
end

