class SubscriptionsMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  def subscribed(subscription)
    @subscription = subscription
    @subscriber = subscription.user
    @owner = subscription.target_user
    mail to: @subscriber.email, subject: "You're now subscribed to #{@owner.name}."
  end

  def unsubscribed(subscription)
    @subscription = subscription
    @subscriber = subscription.user
    @owner = subscription.target_user
    mail to: @subscriber.email, subject: 'You have been unsubscribed.'
  end
end