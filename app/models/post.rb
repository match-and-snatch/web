class Post < ActiveRecord::Base
  include PgSearch
  include Concerns::Likable

  LIKABLE_TYPE = 'Post'.freeze

  belongs_to :user
  has_many :comments
  has_many :uploads, as: :uploadable

  pg_search_scope :search_by_message, against: [:message, :title],
                                      using: [:tsearch, :dmetaphone, :trigram],
                                      ignoring: :accents

  scope :recent, -> { order('created_at DESC, id DESC').limit(5) }

  # @param user [User]
  # @return [Array<Upload>]
  def self.pending_uploads_for(user)
    raise NotImplementedError
  end

  def likable_type
    LIKABLE_TYPE
  end

  def comments_query
    @comments_query ||= Queries::Comments.new(post: self, limit: 3)
  end

  def status?
    type == 'StatusPost'
  end

  def audio?
    type == 'AudioPost'
  end

  def video?
    type == 'VideoPost'
  end

  def photo?
    type == 'PhotoPost'
  end

  def document?
    type == 'DocumentPost'
  end
end
