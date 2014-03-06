class SubscriptionManager < BaseManager

  # @param subscriber [User]
  def initialize(subscriber)
    @subscriber = subscriber
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_and_pay_for(target)
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
