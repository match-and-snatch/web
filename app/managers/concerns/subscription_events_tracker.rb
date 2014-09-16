module Concerns::SubscriptionEventsTracker
  # @param user [User]
  # @param restored [Boolean]
  def subscription_created(user: , restored: false)
    Event.create! user: user, action: 'subscription_created', data: { restored: restored }
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_cancelled(user: , subscription: )
    Event.create! user: user, action: 'subscription_canceled', data: { subscription_id: subscription.id }
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_notifications_enabled(user: , subscription: )
    Event.where(user_id: user.id, action: 'subscription_notifications_disabled', data: { subscription_id: subscription.id }.to_yaml).daily.delete_all
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_notifications_disabled(user: , subscription: )
    Event.create! user: user, action: 'subscription_notifications_disabled', data: { subscription_id: subscription.id }
  end
end