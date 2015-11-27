class MessagesMailer < ApplicationMailer
  def new_message(message)
    @message = message

    return if @message.read?

    return unless @message
    return unless @message.user
    return unless @message.target_user

    mail to: @message.target_user.email, subject: 'New message on ConnectPal'
  end
end

