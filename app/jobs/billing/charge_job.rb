module Billing
  class ChargeJob
    include Concerns::Jobs::Reportable

    def perform
      @report = new_report subscriptions_to_charge: Subscription.to_charge.count('DISTINCT(subscriptions.id)'),
                           skipped_charges: 0,
                           successful_charges: 0,
                           failed_charges: 0

      unless Rails.env.test?
        puts '============================'
        puts '       SUBSCRIPTIONS'
        puts '============================'
      end

      Subscription.to_charge.group('subscriptions.id').find_each do |subscription|
        subscription.reload
        p "Paying for subscription ##{subscription.id}" unless Rails.env.test?

        if subscription.payable?
          begin
            if subscription.user
              SubscriptionManager.new(subscriber: subscription.user, subscription: subscription).pay
              report[:successful_charges] += 1
            else
              report[:skipped_charges] += 1
            end
          rescue ManagerError => e
            puts "Failed paying for subscription ##{subscription.id}: #{e.message}"
            report.log_failure(e.message)
            report[:failed_charges] += 1
          end
        else
          report[:skipped_charges] += 1
        end
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end
  end
end
