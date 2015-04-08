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
    likers_scope = User.joins(:likes).where(likes: {likable_id: id, likable_type: likable_type}).select('profile_name, full_name, holder_name, is_profile_owner').order('likes.created_at DESC')
    likes_count = likes.count

    case likes_count
    when 1, 2
      {recent_liker: likers_scope.map(&:name).join(', '), more_count: 0}
    when 0
        {}
    else
      {recent_liker: likers_scope.first.name, more_count: likes_count - 1}
    end
  end
end
