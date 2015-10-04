class MessagesManager < BaseManager
  attr_reader :user

  # @param user [User] Who is sending the message
  # @param dialogue [Dialogue, nil]
  # @param message [Message, nil]
  def initialize(user: , dialogue: nil, message: nil)
    @user = user
    @dialogue = dialogue
    @message = message
  end

  # @param target_user [User]
  # @param message [String]
  # @param contribution [Contribution] Related contribution
  # @return [Message]
  def create(target_user: , message: , contribution: nil)
    fail_with! message: :empty if message.blank?
    fail_with! message: :too_long if message.length > 1000

    @dialogue = Dialogue.pick(user, target_user)

    unless @dialogue || user.subscribed_to?(target_user) || target_user.subscribed_to?(user)
      fail_with! message: "You can't send a message to this person"
    end

    @message = Message.new(user: user,
                           target_user: target_user,
                           message: message,
                           dialogue: @dialogue,
                           contribution: contribution)
    @message.save!

    EventsManager.message_created(user: @user, message: @message)

    @dialogue.recent_message = @message
    @dialogue.recent_message_at = @message.created_at
    @dialogue.unread = true
    @dialogue.save!

    MessagesMailer.delay.new_message(@message) if target_user.message_notifications_enabled? && !target_user.locked?
    @message
  end

  # @return [Dialogue]
  def mark_as_read
    if user != @dialogue.recent_message.user
      @dialogue.unread = false
      @dialogue.read_at = Time.zone.now
      @dialogue.save!
      EventsManager.dialogue_marked_as_read(user: user, dialogue: @dialogue)
    end
    @dialogue
  end

  def remove
    @dialogue.dialogues_users.where(user_id: @user.id).update_all(removed: true)
  end
end

