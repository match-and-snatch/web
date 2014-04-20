class SubscriptionManager < BaseManager
  include Concerns::CreditCardValidator
  include Concerns::EmailValidator
  include Concerns::PasswordValidator

  attr_reader :subscriber

  # @param subscriber [User]
  def initialize(subscriber)
    @subscriber = subscriber
  end

  # @param email [String]
  # @param full_name [String]
  # @param password [String]
  # @param number [String]
  # @param cvc [String]
  # @param expiry_year [String]
  # @param expiry_month [String]
  # @return [Subscription]
  def register_subscribe_and_pay email: nil,
                                 full_name: nil,
                                 password: nil,
                                 number: nil,
                                 cvc: nil,
                                 expiry_month: nil,
                                 expiry_year: nil,
                                target: (raise ArgumentError)

    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    card = CreditCard.new number:       number,
                          cvc:          cvc,
                          expiry_month: expiry_month,
                          expiry_year:  expiry_year
    validate! do
      fail_with full_name: :empty if full_name.blank?
      validate_email email
      validate_password password: password,
                        password_confirmation: password
      validate_cc card
    end

    auth = AuthenticationManager.new email: email,
                                     full_name: full_name,
                                     password: password,
                                     password_confirmation: password
    if auth.valid_input?
      ActiveRecord::Base.transaction do
        @subscriber = auth.register
        UserProfileManager.new(@subscriber).update_cc_data number: number,
                                                           cvc: cvc,
                                                           expiry_month: expiry_month,
                                                           expiry_year: expiry_year
        subscribe_and_pay_for target
      end
    else
      fail_with! auth.errors
    end
  end

  # @param email [String]
  # @param full_name [String]
  # @param password [String]
  # @param number [String]
  # @param cvc [String]
  # @param expiry_year [String]
  # @param expiry_month [String]
  # @return [Subscription]
  def update_cc_subscribe_and_pay number: nil,
                                  cvc: nil,
                                  expiry_month: nil,
                                  expiry_year: nil,
                                  target: (raise ArgumentError)

    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    card = CreditCard.new number:       number,
                          cvc:          cvc,
                          expiry_month: expiry_month,
                          expiry_year:  expiry_year
    validate! { validate_cc card }

    ActiveRecord::Base.transaction do
      UserProfileManager.new(@subscriber).update_cc_data number: number,
                                                         cvc: cvc,
                                                         expiry_month: expiry_month,
                                                         expiry_year: expiry_year
      subscribe_and_pay_for target
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
      UserStatsManager.new(target.subscription_source_user).log_subscriptions_count
    end
  end

  # @param subscription [Subscription]
  def unsubscribe(subscription)
    subscription.destroy
    UserStatsManager.new(subscription.target_user).log_subscriptions_count
  end
end
