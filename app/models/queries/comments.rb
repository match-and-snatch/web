module Queries
  class Comments
    PER_PAGE = 5

    # @param post [Post]
    # @param performer [User]
    # @param start_id [Integer, nil]
    # @param limit [Integer, nil]
    def initialize(post: nil, performer: post.user, start_id: nil, limit: PER_PAGE)
      @post = post
      @performer = performer
      @start_id = start_id
      @limit = limit
    end

    # @return [Array<Post>]
    def results
      @results ||= basic_scope.to_a.reverse
    end

    def has_more_comments?
      last_comment_id && basic_scope.where(['id < ?', last_comment_id]).any?
    end

    # @return [Integer, nil]
    def last_comment_id
      results.first.try(:id)
    end

    private

    def basic_scope
      comments = @post.comments.order('id DESC').limit(@limit).includes(:user, likes: :user)
      comments = comments.where(parent_id: nil)
      if @performer.id != @post.user_id
        comments = comments.where('hidden = ? OR (hidden = ? AND user_id = ?)', false, true, @performer.id)
      end
      comments = comments.where(['id < ?', @start_id]) if @start_id.present?
      comments
    end
  end
end
