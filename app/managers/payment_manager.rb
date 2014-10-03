class PaymentManager < BaseManager

  attr_reader :user

  # @param user [User, nil]
  def initialize(user: nil)
    @user = user
  end

  # @param target [Concerns::Payable]
  # @param description [String, nil] optional notes on payment
  # @return [Payment, PaymentFailure]
  def pay_for(target, description = nil)
    unless target.is_a?(Concerns::Payable)
      raise ArgumentError, "Don't know how to pay for #{target.class.name}"
    end

    charge = Stripe::Charge.create amount:      target.cost,
                                   customer:    target.customer.stripe_user_id,
                                   currency:    'usd',
                                   description: description,
                                   statement_description: target.target_user.profile_name.first(14).gsub("'", ''),
                                   metadata:    {target_id:   target.id,
                                                 target_type: target.class.name,
                                                 user_id:     target.customer.id}
    Payment.create! target:             target,
                    user:               target.customer,
                    target_user:        target.recipient,
                    amount:             charge['amount'],
                    stripe_charge_data: charge.as_json,
                    description:        description,
                    user_cost:              target.current_cost,
                    user_subscription_fees: target.current_fees,
                    user_subscription_cost: target.total_cost

    target.charged_at = Time.zone.now

    save_or_die!(target).tap do
      target.restore!
      SubscriptionManager.new(subscriber: target.customer, subscription: target).accept
      user_manager = UserManager.new(target.customer)
      user_manager.remove_mark_billing_failed
      user_manager.activate # Anybody who paid us should be activated
    end
  rescue Stripe::StripeError => e
    failure = PaymentFailure.create! exception_data:     "#{e.inspect} | http_body:#{e.http_body} | json_body:#{e.json_body}",
                                     target:             target,
                                     target_user:        target.recipient,
                                     user:               target.customer,
                                     stripe_charge_data: charge.try(:as_json),
                                     description:        description

    SubscriptionManager.new(subscriber: target.customer, subscription: target).tap do |subscription_manager|
      subscription_manager.reject
      subscription_manager.unsubscribe if target.payment_attempts_expired?
    end
    UserManager.new(target.customer).mark_billing_failed
    PaymentsMailer.delay.failed(failure) if target.notify_about_payment_failure?
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
