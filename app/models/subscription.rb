class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, polymorphic: true
  belongs_to :target_user, class_name: 'User'

  validates :user, :target, :target_user, presence: true
end