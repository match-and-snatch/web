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
                    user_cost:              target.target_user.cost,
                    user_subscription_fees: target.target_user.subscription_fees,
                    user_subscription_cost: target.target_user.subscription_cost

    target.charged_at = Time.zone.now

    save_or_die!(target).tap do
      SubscriptionManager.new(target.customer).accept(target)
      UserManager.new(target.customer).remove_mark_billing_failed
    end
  rescue Stripe::StripeError => e
    failure = PaymentFailure.create! exception_data:     "#{e.inspect} | http_body:#{e.http_body} | json_body:#{e.json_body}",
                                     target:             target,
                                     target_user:        target.recipient,
                                     user:               target.customer,
                                     stripe_charge_data: charge.try(:as_json),
                                     description:        description

    PaymentsMailer.delay.failed(failure) if target.notify_about_payment_failure?

    manager = SubscriptionManager.new(target.customer)

    manager.unsubscribe(target) if target.payment_attempts_expired?
    manager.reject(target)

    UserManager.new(target.customer).mark_billing_failed
  end

  # Pays for any random subscription on charge to check if billing fails
  # Changes billing status to "failed" if payment is not passed
  def perform_test_payment
    subscription = user.subscriptions.on_charge.not_removed.first
    pay_for(subscription) if subscription
  end
end
