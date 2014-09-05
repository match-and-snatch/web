class SubscriptionManager < BaseManager
  include Concerns::CreditCardValidator
  include Concerns::EmailValidator
  include Concerns::PasswordValidator

  attr_reader :subscriber, :subscription

  # @param subscriber [User]
  # @param subscription [Subscription]
  def initialize(subscriber: nil, subscription: nil)
    @subscription = subscription
    @subscriber = subscriber || @subscription.try(:user) or raise ArgumentError
  end

  # @param email [String]
  # @param full_name [String]
  # @param password [String]
  # @param number [String]
  # @param cvc [String]
  # @param expiry_year [String]
  # @param expiry_month [String]
  # @return [Subscription]
  def register_subscribe_and_pay(email: nil,
                                 full_name: nil,
                                 password: nil,
                                 number: nil,
                                 cvc: nil,
                                 expiry_month: nil,
                                 expiry_year: nil,
                                 target: )
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

  # @param number [String]
  # @param cvc [String]
  # @param expiry_year [String]
  # @param expiry_month [String]
  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def update_cc_subscribe_and_pay(number: nil,
                                  cvc: nil,
                                  expiry_month: nil,
                                  expiry_year: nil,
                                  target: )
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
      PaymentManager.new.pay_for(subscription, 'Payment for subscription') unless subscription.paid?
    end
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_to(target)
    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    fail_with! "Can't subscribe to self" if @subscriber == target

    removed_subscription = @subscriber.subscriptions.by_target(target).where(removed: true).first

    if removed_subscription
      @subscription = removed_subscription
      restore
    else
      fail_with! 'Already subscribed' if @subscriber.subscriptions.by_target(target).not_removed.any?

      subscription = @subscriber.subscriptions.by_target(target).first || Subscription.new
      subscription.user = @subscriber
      subscription.target = target
      subscription.target_user = target.subscription_source_user

      subscription.current_cost = target.cost
      subscription.current_fees = target.subscription_fees
      subscription.total_cost = target.subscription_cost

      save_or_die! subscription
      @subscription = subscription

      UserStatsManager.new(target.subscription_source_user).log_subscriptions_count
      SubscribedFeedEvent.create! target_user: target, target: @subscriber
      SubscriptionsMailer.delay.subscribed(subscription)
    end

    # Any subscriber should be activated
    UserManager.new(@subscriber).activate

    @subscription
  end

  def restore
    target = @subscription.target

    @subscription.current_cost = target.cost
    @subscription.current_fees = target.subscription_fees
    @subscription.total_cost = target.subscription_cost

    save_or_die! @subscription

    PaymentManager.new.pay_for!(@subscription, 'Payment for subscription') unless @subscription.paid?

    if @subscription.removed?
      @subscription.restore!

      target_user = @subscription.target_user
      UserStatsManager.new(target_user).log_subscriptions_count
      SubscribedFeedEvent.create! target_user: target_user, target: @subscriber
    end
  end

  def unsubscribe
    @subscription.remove!

    target_user = @subscription.target_user
    UserStatsManager.new(target_user).log_subscriptions_count

    if @subscription.rejected?
      # TODO: create another type of event
    else
      UnsubscribedFeedEvent.create! target_user: target_user, target: @subscriber
    end
  end

  def enable_notifications
    @subscription.notifications_enabled = true
    save_or_die! @subscription
  end

  def disable_notifications
    @subscription.notifications_enabled = false
    save_or_die! @subscription
  end

  def reject
    @subscription.rejected = true
    @subscription.rejected_at = Time.zone.now if @subscription.rejected_at.nil?
    save_or_die! @subscription
  end

  def accept
    @subscription.rejected = false
    @subscription.rejected_at = nil
    save_or_die! @subscription
  end
end
