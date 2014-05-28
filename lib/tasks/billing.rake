namespace :billing do
  task cycle: :environment do
    Subscription.on_charge.not_removed.find_each do |subscription|
      p "Paying for #{subscription.id}"
      PaymentManager.new.pay_for(subscription)
    end
  end
end
