class ProfilesMailer < ApplicationMailer
  # @param user [User]
  # @param cost [Integer]
  def changed_cost(user, old_cost, cost)
    @user = user
    @cost = cost
    @old_cost = old_cost
    mail to: 'support@connectpal.com', subject: 'Subscription Notice - Price Change'
  end

  # @param user [User]
  # @param cost [Integer]
  def cost_change_request(user, old_cost, cost)
    @user = user
    @cost = cost
    @old_cost = old_cost
    mail to: APP_CONFIG['emails']['operations'], subject: 'Notice - New Cost Change Request'
  end

  # @param user [User]
  def delete_profile_page_request(user)
    @user = user
    mail to: APP_CONFIG['emails']['operations'], subject: 'Notice - New Delete Profile Page Request'
  end

  # @param user [User]
  # @param cost [Integer]
  def changed_cost_blast(recipient, user, old_cost, cost)
    @user = user
    @cost = cost
    @old_cost = old_cost
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
