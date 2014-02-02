class SubscriptionManager < BaseManager

  # @param subscriber [User]
  def initialize(subscriber)
    @subscriber = subscriber
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_to(target)
    target.is_a?(Concerns::Subscribable) or raise ArgumentError, "Cannot subscribe to #{target.class.name}"

    Subscription.new do |subscription|
      subscription.user = @subscriber
      subscription.target = target
      subscription.target_user = target.subscription_source_user
      subscription.save or fail_with!(subscription.errors)
    end
  end
end