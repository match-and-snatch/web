class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :likable, polymorphic: true
  belongs_to :post

  validates :likable, :user, :target_user, presence: true
end