class Post < ActiveRecord::Base
  include PgSearch

  belongs_to :user
  has_many :comments
  has_many :likes
  has_many :uploads, as: :uploadable

  pg_search_scope :search_by_message, against: :message,
                                      using: [:tsearch, :dmetaphone, :trigram],
                                      ignoring: :accents

  scope :recent, -> { order('created_at DESC, id DESC').limit(5) }

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
