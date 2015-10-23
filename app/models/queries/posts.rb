module Queries
  class Posts

    # @param user [User]
    # @param query [String, nil]
    # @param page [Integer, nil]
    def initialize(user: nil, current_user: user, query: nil, page: nil, limit: nil)
      @user = user
      @current_user = current_user
      @query = query
      @page = [page.to_i, 1].max
      @limit = [limit.try(:to_i) || 5, 50].compact.min
    end

    # @return [Array<Post>]
    def results
      @results ||= begin
                     if @query.present?
                       if tagged?
                         tagged_posts
                       else
                         matching_posts
                       end
                     else
                       recent_posts
                     end
                   end.to_a
    end

    # @return [Boolean]
    def has_more?
      results.any? # TODO: FIX ME
    end

    def user_input?
      @page == 1 && !@query.nil?
    end

    private

    def tagged?
      @query.match(/#audio|#video|#document|#photo|#document|#status/i)
    end

    def types
      @query
          .split(/\W+/)
          .map { |x| x.singularize.camelize << 'Post' } & %w(AudioPost VideoPost PhotoPost DocumentPost StatusPost)
    end

    def matching_posts
      Queries::Elastic::Posts.search(user_id: @user.id,
                                     fulltext_query: @query,
                                     include_hidden: include_hidden?,
                                     from: (@page - 1) * @limit,
                                     size: @limit).records
    end

    def tagged_posts
      recent_posts(type: types)
    end

    def recent_posts(scope = {})
      posts = @user.posts.where(scope)
      unless include_hidden?
        posts = posts.where(hidden: false)
      end
      posts.includes(likes: :user).order(created_at: :desc).page(@page).per(@limit)
    end

    def include_hidden?
      @user != @current_user
    end
  end
end
