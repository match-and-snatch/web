class Dialogue < ApplicationRecord
  has_many :dialogues_users
  has_many :users, through: :dialogues_users
  has_many :messages
  belongs_to :recent_message, class_name: 'Message'

  scope :by_user, -> (user) { joins(:users).where(users: {id: user.id}) }
  scope :unread, -> { where(unread: true) }

  # Finds or creates dialogue between users
  # @param user [User]
  # @param target_user [User]
  # @return [Dialogue]
  def self.pick(user, target_user)
    dialogue = joins(:users).
      where(users: {id: [user.id, target_user.id]}).
      group('dialogues.id').having('COUNT(users.id) = 2').first

    if dialogue
      dialogue.dialogues_users.update_all(removed: false)
    else
      dialogue = Dialogue.new
      dialogue.unread = false
      dialogue.dialogues_users.build(user: user)
      dialogue.dialogues_users.build(user: target_user)
      dialogue.save!
    end

    dialogue
  end

  # Returns second person involved in dialogue
  # @param user [User]
  # @return [User]
  def antiuser(user)
    users.where(['users.id <> ?', user.id]).first
  end
end

