class MessagesMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  def new_message(message)
    @message = message

    return unless @message
    return unless @message.user
    return unless @message.target_user

    mail to: @message.target_user.email, subject: 'New message on ConnectPal'
  end
end

