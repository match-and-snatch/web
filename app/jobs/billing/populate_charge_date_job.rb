module Billing
  class PopulateChargeDateJob
    def self.perform
      Subscription.where.not(charged_at: nil).find_each do |subscription|
        subscription.update charge_date: subscription.charged_at.next_month
      end
    end
  end
end
