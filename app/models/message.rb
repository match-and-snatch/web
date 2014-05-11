class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'

  validate :message, presence: true
end
