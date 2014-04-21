class AuthMailer < ApplicationMailer

  # @param user [User]
  def forgot_password(user)
    @user = user
    mail to: @user.email, subject: 'Requested password change'
  end

  # @param user [User]
  def registered(user)
    @user = user
    mail to: @user.email, subject: 'Welcome to ConnectPal!'
  end
end