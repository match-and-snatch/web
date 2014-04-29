class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :post_user, class_name: 'User', foreign_key: :post_user_id
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id
  belongs_to :parent, class_name: 'Comment', foreign_key: :parent_id

  validates :message, presence: true
end