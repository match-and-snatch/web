class PaymentManager < BaseManager

  attr_reader :user

  # @param user [User, nil]
  def initialize(user: nil)
    @user = user
  end

  def create_charge(amount: , customer: nil, description: nil, statement_description: nil, metadata: {})
    fail_with! 'Credit card is declined' if @user.cc_declined?
    fail_with! 'Account locked' if @user.locked?

    Stripe::Charge.create amount: amount,
                          customer: (customer || user.try(:stripe_user_id)),
                          currency: 'usd',
                          description: cut_adult_words(description),
                          statement_description: cut_adult_words(statement_description).gsub(/\W+/, '').first(14),
                          metadata: metadata
  end

  # @param subscription [Concerns::Payable]
  # @param description [String, nil] optional notes on payment
  # @return [Payment, PaymentFailure]
  def pay_for(subscription, description = nil)
    unless subscription.is_a?(Concerns::Payable)
      raise ArgumentError, "Don't know how to pay for #{subscription.class.name}"
    end

    @user ||= subscription.customer

    charge = create_charge amount: subscription.total_cost,
                           customer:    subscription.customer.stripe_user_id,
                           description: description,
                           statement_description: subscription.target_user.profile_name,
                           metadata: { target_id:   subscription.id,
                                       target_type: subscription.class.name,
                                       user_id:     subscription.customer.id }

    payment = Payment.create! target:             subscription,
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
      SubscriptionManager.new(subscriber: subscription.customer, subscription: subscription).tap do |subscription_manager|
        subscription_manager.accept
        subscription_manager.unmark_as_processing if subscription.processing_payment?
      end
      EventsManager.payment_created(user: user, payment: payment)
      user_manager = UserManager.new(subscription.customer)
      user_manager.remove_mark_billing_failed
      UserStatsManager.new(subscription.target_user).log_subscriptions_count
      user_manager.activate # Anybody who paid us should be activated
    end
  rescue Stripe::CardError => e
    failure = create_failure(e: e, subscription: subscription, charge: charge, description: description)
    SubscriptionManager.new(subscriber: subscription.customer, subscription: subscription).tap do |subscription_manager|
      subscription_manager.reject
      subscription_manager.unsubscribe if subscription.payment_attempts_expired?
    end
    UserManager.new(subscription.customer).mark_billing_failed
    PaymentsMailer.delay.failed(failure) if subscription.notify_about_payment_failure?
    UserStatsManager.new(subscription.target_user).log_subscriptions_count
    failure
  rescue Stripe::StripeError => e
    SubscriptionManager.new(subscriber: subscription.customer, subscription: subscription).mark_as_processing
    create_failure(e: e, subscription: subscription, charge: charge, description: description)
  end

  def pay_for!(*args)
    pay_for(*args).tap do |result|
      fail_with!('Payment has been failed', PaymentError) if result.is_a? PaymentFailure
    end
  end

  # Pays for any random subscription on charge to check if billing fails
  # Changes billing status to "failed" if payment is not passed
  def perform_test_payment
    subscription = user.subscriptions.to_charge.first
    SubscriptionManager.new(subscription: subscription).pay if subscription
  end

  private

  # @return [PaymentFailure]
  def create_failure(e: , subscription: , charge: , description: nil)
    failure = PaymentFailure.create! exception_data:     "#{e.inspect} | http_body:#{e.http_body} | json_body:#{e.json_body}",
                                     target:             subscription,
                                     target_user:        subscription.recipient,
                                     user:               subscription.customer,
                                     stripe_charge_data: charge.try(:as_json),
                                     description:        description

    if e.json_body.try(:[], :error).try(:[], :decline_code) == 'fraudulent'
      UserManager.new(subscription.customer).lock(:billing)
    end

    EventsManager.payment_failed(user: user, payment_failure: failure)
    failure
  end

  def cut_adult_words(sentence = nil)
    sentence.to_s.gsub(APP_CONFIG['adult_filter_regex'], '').squish
  end
end
