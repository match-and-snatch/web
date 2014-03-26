class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  belongs_to :post_user, class_name: 'User', foreign_key: :post_user_id

  validates :message, presence: true

  def self.recent
    order('id DESC').limit(5).to_a.reverse
  end
end