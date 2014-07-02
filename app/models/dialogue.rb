class Dialogue < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :recent_message, class_name: 'Message'

  has_many :messages

  scope :by_user, -> (user) { where(['dialogues.user_id = ? OR dialogues.target_user_id = ?', user.id, user.id]) }
  scope :unread, -> { where(unread: true) }

  # Finds or creates dialogue between users
  # @param user [User]
  # @param target_user [User]
  # @return [Dialogue]
  def self.pick(user, target_user)
    dialogue = by_user(user).by_user(target_user).first
    dialogue || Dialogue.create!(user: user, target_user: target_user)
  end

  def antiuser(user)
    user == self.user ? target_user : self.user
  end
end

