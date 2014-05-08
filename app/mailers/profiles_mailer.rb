class ProfilesMailer < ApplicationMailer

  def changed_cost(user, cost)
    @user = user
    @cost = cost
    mail to: 'support@connectpal.com', subject: 'Requested cost change'
  end
end