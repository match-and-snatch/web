class ProfilesMailer < ApplicationMailer

  # @param user [User]
  # @param cost [Integer]
  def changed_cost(user, cost)
    @user = user
    @cost = cost
    mail to: 'support@connectpal.com', subject: 'Requested cost change'
  end

  # @param subscription [Subscription]
  def vacation_enabled(subscription)
    @subscriber = subscription.user
    @profile_owner = subscription.target_user
    mail to: @subscriber.email, subject: "#{@profile_owner.name} has gone on vacation"
  end

  # @param subscription [Subscription]
  def vacation_disabled(subscription)
    @subscriber = subscription.user
    @profile_owner = subscription.target_user
    mail to: @subscriber.email, subject: "#{@profile_owner.name} has returned from vacation"
  end
end
