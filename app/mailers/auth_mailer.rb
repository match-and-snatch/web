class AuthMailer < ApplicationMailer

  # @param user [User]
  def forgot_password(user)
    @user = user
    mail to: @user.email, subject: 'Requested password change'
  end
end