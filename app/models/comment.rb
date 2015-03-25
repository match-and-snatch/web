class Comment < ActiveRecord::Base
  include Concerns::Likable

  serialize :mentions, Hash

  belongs_to :post
  belongs_to :user
  belongs_to :post_user, class_name: 'User', foreign_key: :post_user_id
  belongs_to :parent, class_name: 'Comment', foreign_key: :parent_id
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id

  validates :message, presence: true

  def mentioned_users
    User.where(id: mentions.keys)
  end

  def target_user
    post_user
  end
end
