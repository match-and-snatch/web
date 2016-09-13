class Message < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :dialogue
  belongs_to :contribution, inverse_of: :message

  validates :message, presence: true

  scope :recent, -> { order(created_at: :desc).limit(30).reverse }
  scope :unread, -> { where(read: false) }
end
