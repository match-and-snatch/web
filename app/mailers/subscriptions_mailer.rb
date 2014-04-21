class SubscriptionsMailer < ApplicationMailer

  # @param user [User]
  def subscribed(user)
    @user = user
    mail to: @user.email, subject: 'Subscribed'
  end

  # @param user [User]
  def unsubscribed(user)
    @user = user
    mail to: @user.email, subject: 'Unsubscribed'
  end
end
