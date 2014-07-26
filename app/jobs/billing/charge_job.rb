module Billing
  class ChargeJob
    def self.perform
      Subscription.on_charge.not_removed.find_each do |subscription|
        p "Paying for #{subscription.id}" unless Rails.env.test?
        PaymentManager.new.pay_for(subscription)
      end
    end
  end
end

