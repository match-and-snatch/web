class Message < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :dialogue
  belongs_to :contribution, inverse_of: :message

  validate :message, presence: true

  scope :recent, -> { order(created_at: :desc).limit(30).reverse }
end
