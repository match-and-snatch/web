class Post < ActiveRecord::Base
  include Elasticpal::Indexable
  include Concerns::Likable

  LIKABLE_TYPE = 'Post'.freeze

  belongs_to :user, counter_cache: true
  has_many :comments
  has_many :uploads, as: :uploadable

  scope :pinned, -> { where(pinned: true) }

  elastic_index 'posts' do
    elastic_type do
      field :message, :title
      field :user_id
      field :hidden
      field :pinned
      field :type
      field(:created_at) { created_at.to_i }
    end
  end

  # @param user [User]
  # @return [Array<Upload>]
  def self.pending_uploads_for(user)
    raise NotImplementedError
  end

  def likable_type
    LIKABLE_TYPE
  end

  # @param performer [User]
  def comments_query(performer: user)
    @comments_query ||= Queries::Comments.new(post: self, limit: 3, performer: performer)
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
