module Concerns::Likable
  extend ActiveSupport::Concern

  included do
    has_many :likes
  end

  def likable_type
    self.class.name
  end

  # @todo move to decorator
  # @return [Hash]
  def likers_data
    likers_scope = likes.sort_by(&:created_at).reverse.map(&:user)
    likes_count = likes.size

    case likes_count
    when 1, 2
      {recent_liker: likers_scope.map(&:name).join(', '), more_count: 0, total_count: likes_count}
    when 0
      {total_count: likes_count}
    else
      {recent_liker: likers_scope.first.name, more_count: likes_count - 1, total_count: likes_count}
    end
  end
end
