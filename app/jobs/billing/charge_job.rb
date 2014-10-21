module Billing
  class ChargeJob
    def self.perform
      Subscription.on_charge.not_removed.where(users: { vacation_enabled: false, has_suspended_billing: false }).find_each do |subscription|
        p "Paying for #{subscription.id}" unless Rails.env.test?
        PaymentManager.new.pay_for(subscription) if subscription.user
      end
    end
  end
end

