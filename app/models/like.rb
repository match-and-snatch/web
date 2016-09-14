class Like < ApplicationRecord
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :likable, polymorphic: true
  belongs_to :post, counter_cache: true
  belongs_to :comment, counter_cache: true

  validates :likable, :user, :target_user, presence: true
end
