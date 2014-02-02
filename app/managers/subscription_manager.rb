class SubscriptionManager < BaseManager

  # @param subscriber [User]
  def initialize(subscriber)
    @subscriber = subscriber
  end

  # @param target [Concerns::Subscribable]
  # @return [Subscription]
  def subscribe_to(target)
    fail_with! "Cannot subscribe to #{target.class.name}" unless target.is_a?(Concerns::Subscribable)

    Subscription.new do |subscription|
      subscription.user = @subscriber
      subscription.target = target
      subscription.target_user = target.subscription_source_user
      subscription.save or fail_with!(subscription.errors)
    end
  end
end