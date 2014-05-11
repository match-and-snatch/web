class Dialogue < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :recent_message, class_name: 'Message'

  # Finds or creates dialogue between users
  # @param user [User]
  # @param target_user [User]
  # @return [Dialogue]
  def self.pick(user, target_user)
    dialogue = where(user_id: user.id, target_user_id: target_user.id).first
    dialogue || Dialogue.create!(user: user, target_user: target_user)
  end
end

