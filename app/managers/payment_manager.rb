class PaymentManager < BaseManager

  attr_reader :user

  # @param user [User, nil]
  def initialize(user: nil)
    @user = user
  end

  # @param subscription [Concerns::Payable]
  # @param description [String, nil] optional notes on payment
  # @return [Payment, PaymentFailure]
  def pay_for(subscription, description = nil)
    unless subscription.is_a?(Concerns::Payable)
      raise ArgumentError, "Don't know how to pay for #{subscription.class.name}"
    end

    charge = Stripe::Charge.create amount:      subscription.total_cost,
                                   customer:    subscription.customer.stripe_user_id,
                                   currency:    'usd',
                                   description: description,
                                   statement_description: subscription.target_user.profile_name.first(14).gsub("'", ''),
                                   metadata:    { target_id:   subscription.id,
                                                  target_type: subscription.class.name,
                                                  user_id:     subscription.customer.id }

    Payment.create! target:             subscription,
                    user:               subscription.customer,
                    target_user:        subscription.recipient,
                    amount:             charge['amount'],
                    stripe_charge_data: charge.as_json,
                    description:        description,
                    cost:              subscription.cost,
                    subscription_fees: subscription.fees,
                    subscription_cost: subscription.total_cost

    subscription.charged_at = Time.zone.now

    save_or_die!(subscription).tap do
      subscription.restore!
      SubscriptionManager.new(subscriber: subscription.customer, subscription: subscription).accept
      EventsManager.payment_created(user: user)
      user_manager = UserManager.new(subscription.customer)
      user_manager.remove_mark_billing_failed
      user_manager.activate # Anybody who paid us should be activated
    end
  rescue Stripe::StripeError => e
    failure = PaymentFailure.create! exception_data:     "#{e.inspect} | http_body:#{e.http_body} | json_body:#{e.json_body}",
                                     target:             subscription,
                                     target_user:        subscription.recipient,
                                     user:               subscription.customer,
                                     stripe_charge_data: charge.try(:as_json),
                                     description:        description

    SubscriptionManager.new(subscriber: subscription.customer, subscription: subscription).tap do |subscription_manager|
      subscription_manager.reject
      subscription_manager.unsubscribe if subscription.payment_attempts_expired?
    end
    UserManager.new(subscription.customer).mark_billing_failed
    PaymentsMailer.delay.failed(failure) if subscription.notify_about_payment_failure?
    EventsManager.payment_failed(user: user)
    failure
  end

  def pay_for!(*args)
    pay_for(*args).tap do |result|
      fail_with! 'Payment has been failed' if result.is_a? PaymentFailure
    end
  end

  # Pays for any random subscription on charge to check if billing fails
  # Changes billing status to "failed" if payment is not passed
  def perform_test_payment
    subscription = user.subscriptions.on_charge.not_removed.first
    pay_for(subscription) if subscription
  end
end
