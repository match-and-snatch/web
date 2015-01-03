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

  # @param user [User]
  def liked_by?(user)
    feedbacks.where(positive: true).where(user_id: user.id).exists?
  end

  # @param user [User]
  def disliked_by?(user)
    feedbacks.where(positive: false).where(user_id: user.id).exists?
  end

  def positive_feedback_percentage
    total_count = feedbacks.count

    if total_count.zero?
      0.0
    else
      (feedbacks.where(positive: true).count.to_f / total_count).round(2) * 100
    end
  end

  def negative_feedback_percentage
    if feedbacks.count.zero?
      0.0
    else
      100.0 - positive_feedback_percentage
    end
  end
end