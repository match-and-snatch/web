module Concerns::Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes
  end

  # @todo move to decorator
  # @return [Hash]
  def likers_data
    likes_count = likes.count
    likes_scope = likes.order('likes.created_at DESC').joins(:user).select('coalesce(users.profile_name, users.full_name) as name')

    case likes_count
    when 1, 2
      {recent_liker: likes_scope.map(&:name).join(', '), more_count: 0}
    when 0
        {}
    else
      {recent_liker: likes_scope.first.name, more_count: likes_count - 1}
    end
  end
end
