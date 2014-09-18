module Concerns::Events::SubscriptionTracker
  # @param user [User]
  # @param subscription [Subscription]
  # @param restored: [Boolean]
  def subscription_created(user: , subscription: , restored: false)
    Event.create! user: user,
                  action: 'subscription_created',
                  data: { subscription_id: subscription.id,
                          target_user_id:  subscription.target_user_id,
                          restored:        restored }
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_cancelled(user: , subscription: )
    Event.create! user: user,
                  action: 'subscription_canceled',
                  data: { subscription_id: subscription.id,
                          target_user_id:  subscription.target_user_id }
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_notifications_enabled(user: , subscription: )
    Event.where(user_id: user.id,
                action: 'subscription_notifications_disabled',
                data: { subscription_id: subscription.id,
                        target_user_id:  subscription.target_user_id }.to_yaml).daily.delete_all
  end

  # @param user [User]
  # @param subscription [Subscription]
  def subscription_notifications_disabled(user: , subscription: )
    Event.create! user: user,
                  action: 'subscription_notifications_disabled',
                  data: { subscription_id: subscription.id,
                          target_user_id:  subscription.target_user_id }
  end
end