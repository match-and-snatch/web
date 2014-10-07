class MessagesManager < BaseManager
  attr_reader :user

  # @param user [User] Who is sending the message
  # @param dialogue [Dialogue, nil]
  def initialize(user: , dialogue: nil)
    @user = user
    @dialogue = nil
  end

  # @param target_user [User]
  # @param message [String]
  # @return [Message]
  def create(target_user: , message: )
    fail_with! message: :empty if message.blank?
    fail_with! message: :too_long if message.length > 1000

    @dialogue = Dialogue.pick(user, target_user)

    _message = Message.new(user: user, target_user: target_user, message: message, dialogue: @dialogue)
    _message.save!
    @dialogue.recent_message = _message
    @dialogue.recent_message_at = _message.created_at
    @dialogue.unread = true
    @dialogue.save!

    MessagesMailer.delay.new_message(_message)
    _message
  end

  def mark_as_read
    if user != @dialogue.recent_message.user
      @dialogue.unread = false
      @dialogue.read_at = Time.zone.now
      @dialogue.save!
    end
    @dialogue
  end
end

