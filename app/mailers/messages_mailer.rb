class MessagesMailer < ApplicationMailer
  add_template_helper ApplicationHelper

  def new_message(message)
    @message = message
    mail to: @message.target_user.email, subject: 'New message on ConnectPal'
  end
end

