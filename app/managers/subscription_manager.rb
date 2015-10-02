class SubscriptionManager < BaseManager
  include Concerns::CreditCardValidator
  include Concerns::EmailValidator
  include Concerns::PasswordValidator

  attr_reader :subscriber, :subscription

  # @param count [Integer]
  # @param target_user [User] profile owner
  def self.create_fakes(count: , target_user: )
    count = count.to_i
    subscriptions = Subscription.where(target_user_id: target_user.id, fake: true, removed: false)
    difference = subscriptions.count - count

    if difference > 0
      subscriptions.limit(difference).each do |s|
        self.new(subscriber: s.user, subscription: s).unsubscribe
      end
    else
      difference.abs.times do
        self.new(subscriber: User.fake).subscribe_to(target_user, fake: true)
      end
    end
  end

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
  # @param address_line_1 [String]
  # @param address_line_2 [String]
  # @param state [String]
  # @param city [String]
  # @param zip [String]
  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def register_subscribe_and_pay(email: nil,
                                 full_name: nil,
                                 password: nil,
                                 number: nil,
                                 cvc: nil,
                                 expiry_month: nil,
                                 expiry_year: nil,
                                 zip: nil,
                                 city: nil,
                                 state: nil,
                                 address_line_1: nil,
                                 address_line_2: nil,
                                 target: )
    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    card = CreditCard.new number:       number,
                          cvc:          cvc,
                          expiry_month: expiry_month,
                          expiry_year:  expiry_year,
                          zip: zip,
                          city: city,
                          state: state,
                          holder_name: full_name,
                          address_line_1: address_line_1,
                          address_line_2: address_line_2
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
                                                           expiry_year: expiry_year,
                                                           zip: zip,
                                                           city: city,
                                                           state: state,
                                                           address_line_1: address_line_1,
                                                           address_line_2: address_line_2
      end
      subscribe_and_pay_for target
    else
      fail_with! auth.errors
    end
  end

  # @param number [String]
  # @param cvc [String]
  # @param expiry_year [String]
  # @param expiry_month [String]
  # @param address_line_1 [String]
  # @param address_line_2 [String]
  # @param state [String]
  # @param city [String]
  # @param zip [String]
  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def update_cc_subscribe_and_pay(number: nil,
                                  cvc: nil,
                                  expiry_month: nil,
                                  expiry_year: nil,
                                  zip: nil,
                                  city: nil,
                                  state: nil,
                                  address_line_1: nil,
                                  address_line_2: nil,
                                  target: )
    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    card = CreditCard.new number:       number,
                          holder_name:  subscriber.try(:full_name),
                          cvc:          cvc,
                          expiry_month: expiry_month,
                          expiry_year:  expiry_year,
                          zip: zip,
                          city: city,
                          state: state,
                          address_line_1: address_line_1,
                          address_line_2: address_line_2
    validate! { validate_cc card }

    ActiveRecord::Base.transaction do
      UserProfileManager.new(@subscriber).update_cc_data number: number,
                                                         cvc: cvc,
                                                         expiry_month: expiry_month,
                                                         expiry_year: expiry_year,
                                                         zip: zip,
                                                         city: city,
                                                         state: state,
                                                         address_line_1: address_line_1,
                                                         address_line_2: address_line_2
      subscribe_and_pay_for target
    end
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_and_pay_for(target)
    unless @subscriber.has_cc_payment_account?
      raise ArgumentError, 'Subscriber does not have CC accout'
    end

    fail_with! 'Credit card is declined' if @subscriber.cc_declined?

    subscribe_to(target, &method(:pay))
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_to(target, fake: false, &block)
    unless target.is_a?(Concerns::Subscribable)
      raise ArgumentError, "Cannot subscribe to #{target.class.name}"
    end

    fail_locked! if @subscriber.locked?
    fail_with! "Can't subscribe to self" if @subscriber == target
    fail_with! "Can't subscribe to user with not approved cost" unless target.cost_approved?

    # Never restore removed fake subscriptions
    removed_subscription = @subscriber.subscriptions.by_target(target).where(removed: true, fake: false).first

    if removed_subscription
      @subscription = removed_subscription
      restore
    else
      unless fake
        fail_with! 'Already subscribed' if @subscriber.subscriptions.by_target(target).not_removed.any?
        subscription = @subscriber.subscriptions.by_target(target).first

        recent_subscriptions_count = @subscriber.recently_subscribed? ? @subscriber.recent_subscriptions_count : 0
      end

      subscription ||= Subscription.new
      subscription.user = @subscriber
      subscription.target = target
      subscription.target_user = target.subscription_source_user
      subscription.fake = fake

      save_or_die! subscription

      @subscription = subscription
      @subscription.actualize_cost! or fail_with! @subscription.errors

      block.try(:call)

      UserStatsManager.new(target.subscription_source_user).log_subscriptions_count
      unless fake
        user_manager = UserManager.new(@subscriber)
        user_manager.lock if recent_subscriptions_count >= 4
        user_manager.log_recent_subscriptions_count(recent_subscriptions_count + 1)
      end
      @subscription
    end

    # Any subscriber should be activated
    UserManager.new(@subscriber).activate

    @subscription
  end

  def pay
    return if @subscription.paid?
    been_charged = @subscription.charged_at.present?

    PaymentManager.new(user: @subscriber).pay_for!(@subscription, 'Payment for subscription').tap do
      populate_subscription_events unless been_charged
    end
  end

  def restore
    @subscription.actualize_cost! or fail_with! @subscription.errors

    if @subscription.paid?
      accept if @subscription.rejected?
    else
      pay
    end

    if @subscription.removed?
      @subscription.restore!
      populate_subscription_events(restored: true)
    end
  end

  def unsubscribe
    @subscription.remove!

    target_user = @subscription.target_user
    UserStatsManager.new(target_user).log_subscriptions_count

    if @subscription.rejected?
      # TODO: create another type of event
    else
      unless @subscription.fake?
        UnsubscribedFeedEvent.create! target_user: target_user, target: @subscriber
        SubscribedFeedEvent.by_users(owner: target_user, subscriber: @subscriber).last.try(:hide!)
      end
      EventsManager.subscription_cancelled(user: @subscriber, subscription: @subscription)
    end
  end

  def unsubscribe_entirely
    @subscriber.subscriptions.not_removed.find_each do |subscription|
      self.class.new(subscriber: @subscriber, subscription: subscription).unsubscribe
    end
  end

  def enable_notifications
    @subscription.notifications_enabled = true
    save_or_die! @subscription
    EventsManager.subscription_notifications_enabled(user: @subscriber, subscription: @subscription)
    @subscription
  end

  def disable_notifications
    @subscription.notifications_enabled = false
    save_or_die! @subscription
    EventsManager.subscription_notifications_disabled(user: @subscriber, subscription: @subscription)
    @subscription
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

  private

  def populate_subscription_events(restored: false)
    target_user = @subscription.target_user
    UserStatsManager.new(target_user).log_subscriptions_count
    if @subscription.fake
      # DO NOTHING
    elsif restored
      SubscribedFeedEvent.by_users(owner: target_user, subscriber: @subscriber).last.try(:show!)
    else
      SubscribedFeedEvent.create!(target_user: target_user, target: @subscriber)
      SubscriptionsMailer.delay.subscribed(@subscription)
    end
    EventsManager.subscription_created(user: @subscriber, subscription: @subscription, restored: restored)
  end
end
