class ProfilesMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  # @param user [User]
  # @param cost [Integer]
  def changed_cost(user, old_cost, cost)
    @user = user
    @cost = cost / 100.0
    @old_cost = old_cost / 100.0
    mail to: 'support@connectpal.com', subject: 'Subscription Notice - Price Change'
  end

  # @param user [User]
  # @param cost [Integer]
  def changed_cost_blast(recipient, user, old_cost, cost)
    @user = user
    @cost = cost / 100.0
    @old_cost = old_cost / 100.0
    mail to: recipient.email, subject: 'Subscription Notice - Price Change'
  end

  # @param subscription [Subscription]
  def vacation_enabled(subscription)
    @subscriber = subscription.user
    @profile_owner = subscription.target_user
    mail to: @subscriber.email, subject: "#{@profile_owner.name} has gone on away mode"
  end

  # @param subscription [Subscription]
  def vacation_disabled(subscription)
    @subscriber = subscription.user
    @profile_owner = subscription.target_user
    mail to: @subscriber.email, subject: "#{@profile_owner.name} has returned from away mode"
  end
end
