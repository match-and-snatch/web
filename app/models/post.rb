class Post < ActiveRecord::Base
  include Elasticpal::Indexable
  include Concerns::Likable

  LIKABLE_TYPE = 'Post'.freeze

  belongs_to :user
  has_many :comments
  has_many :uploads, as: :uploadable

  elastic_index 'posts' do
    elastic_type do
      field :message, :title
      field :user_id
      field :hidden
      field :type
      field(:created_at) { created_at.to_i }
    end
  end

  scope :recent, -> (limit = 5) { order('created_at DESC, id DESC').limit(limit) }

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
