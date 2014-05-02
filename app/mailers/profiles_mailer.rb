class ProfilesMailer < ApplicationMailer

  def changed_cost(user)
    @user = user
    mail to: 'support@connectpal.com', subject: 'Requested cost change'
  end
end