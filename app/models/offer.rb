class Offer < ActiveRecord::Base
  belongs_to :user
  has_many :favorites
  has_many :offers_tags
  has_many :tags, through: :offers_tags
  has_many :feedbacks
  has_many :subscriptions
  has_many :messages

  # @param user [User]
  def favorited_by?(user)
    favorites.where(user_id: user.id).exists?
  end
end