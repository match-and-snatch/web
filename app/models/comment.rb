class Comment < ActiveRecord::Base
  include Concerns::Likable

  serialize :mentions, Hash

  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :post_user, class_name: 'User', foreign_key: :post_user_id
  belongs_to :parent, class_name: 'Comment', foreign_key: :parent_id, counter_cache: :replies_count
  has_many :replies, class_name: 'Comment', foreign_key: :parent_id

  validates :message, presence: true

  def mentioned_users
    User.where(id: mentions.keys)
  end

  def target_user
    post_user
  end

  def user_picture_url
    user.comment_picture_url(profile_image: user_id == post_user_id)
  end
end
