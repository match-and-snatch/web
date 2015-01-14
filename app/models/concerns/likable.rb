module Concerns::Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes
  end

  # @todo move to decorator
  def likers_text
    likes_count = likes.count

    if likes_count > 0
      recent_likes = likes.order('likes.created_at DESC').limit(2).joins(:user).select('users.full_name as name').map(&:name)
      recent_likes = recent_likes.join(', ')
      likes_count -= 2

      if likes_count < 1
        recent_likes
      elsif likes_count == 1
        "#{recent_likes} and 1 other"
      else
        "#{recent_likes} and #{likes_count} others"
      end
    end
  end
end
