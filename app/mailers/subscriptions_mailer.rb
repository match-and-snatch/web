class SubscriptionsMailer < ApplicationMailer
  def subscribed(subscription)
    @subscription = subscription
    @subscriber = subscription.user
    @target_user = subscription.target_user
    mail to: @subscriber.email, subject: "You're now subscribed to #{@target_user.name}."
  end

  def unsubscribed(subscription)
    @subscription = subscription
    @subscriber = subscription.user
    @target_user = subscription.target_user
    mail to: @subscriber.email, subject: 'You have been unsubscribed.'
  end
end
