class SubscriptionManager < BaseManager

  # @param subscriber [User]
  def initialize(subscriber)
    @subscriber = subscriber
  end

  def register_and_subscribe email: nil,
                             full_name: nil,
                             password: nil,
                             number: nil,
                             cvc: nil,
                             expiry_month: nil,
                             expiry_year: nil
    number       = number      .to_s.gsub /\D/, ''
    cvc          = cvc         .to_s.gsub /\D/, ''
    expiry_month = expiry_month.to_s.gsub /\D/, ''
    expiry_year  = expiry_year .to_s.gsub /\D/, ''

    validate! do
      fail_with full_name: :empty if full_name.blank?

      fail_with email: :empty if email.blank?
      fail_with :email unless email.match(EMAIL_REGEXP)
      fail_with email: :taken if email_taken?

      fail_with password: {too_short: {minimum: 5}} if password.to_s.length < 5

      fail_with :number      if number.blank? || number.length < 16
      fail_with :cvc         if cvc   .blank? || cvc   .length < 3
      fail_with :expiry_date if expiry_month.blank? || expiry_year.blank? || expiry_month.to_i > 12 || expiry_month.to_i < 1 || expiry_year.to_i < 14
    end


 end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_and_pay_for(target)
    unless @subscriber.has_cc_payment_account?
      raise ArgumentError, 'Subscriber does not have CC accout'
    end

    subscribe_to(target).tap do |subscription|
      PaymentManager.new.pay_for(subscription, 'Payment for subscription')
    end
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_to(target)
    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    fail_with! "Can't subscribe to self" if @subscriber == target
    fail_with! 'Already subscribed' if @subscriber.subscribed_to?(target)

    Subscription.new do |subscription|
      subscription.user        = @subscriber
      subscription.target      = target
      subscription.target_user = target.subscription_source_user

      subscription.save or fail_with!(subscription.errors)
    end
  end
end
