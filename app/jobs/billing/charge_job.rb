module Billing
  class ChargeJob
    def self.perform
      unless Rails.env.test?
        puts "============================"
        puts "       SUBSCRIPTIONS"
        puts "============================"
      end

      Subscription.to_charge.find_each do |subscription|
        p "Paying for subscription ##{subscription.id}" unless Rails.env.test?
        begin
          SubscriptionManager.new(subscriber: subscription.user, subscription: subscription).pay if subscription.user
        rescue ManagerError => e
          puts "Failed paying for subscription ##{subscription.id}: #{e.message}"
        end
      end
    end
  end
end

