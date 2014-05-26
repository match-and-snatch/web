namespace :billing do
  task cycle: :environment do
    Subscription.on_charge.order('id DESC').each do |subscription|
      p "Paying for #{subscription.id}"
      PaymentManager.new.pay_for(subscription)
    end
  end
end
