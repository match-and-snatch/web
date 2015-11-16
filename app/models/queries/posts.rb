module Queries
  class Posts

    # @param user [User]
    # @param query [String, nil]
    # @param start_id [Integer, nil]
    def initialize(user: nil, current_user: user, query: nil, start_id: nil, limit: nil)
      @user = user
      @current_user = current_user
      @query = query
      @start_id = start_id
      @limit = [limit.try(:to_i) || 5, 50].compact.min
    end

    # @return [Array<Post>]
    def results
      @results ||= begin
                     if @query.present?
                       posts = matching_posts.records
                     else
                       posts = recent_posts
                       posts = posts.where(['id < ?', @start_id]) if @start_id.present?

                       unless include_hidden?
                         posts = posts.where(hidden: false)
                       end
                     end

                     posts
                   end.to_a
    end

    def autocomplete?
      !@query.nil?
    end

    # @return [Integer, nil]
    def last_post_id
      results.last.try(:id)
    end

    def user_input?
      !(not_a_first_page? || !autocomplete?)
    end

    private

    def not_a_first_page?
      @start_id.present?
    end

    def tagged?
      @query.include?('#')
    end

    def types
      @query
        .split(/\W+/)
        .map(&:singularize).map(&:camelize)
        .map { |x| x << 'Post' } & %w(AudioPost VideoPost PhotoPost DocumentPost StatusPost)
    end

    def matching_posts
      if tagged?
        Queries::Elastic::PostsByType.search(user_id: @user.id,
                                             tags: types,
                                             include_hidden: include_hidden?)
      else
        Queries::Elastic::Posts.search(user_id: @user.id,
                                       fulltext_query: @query,
                                       include_hidden: include_hidden?)
      end
    end

    def recent_posts
      @user.posts.recent(@limit)
    end

    def include_hidden?
      @user != @current_user
    end
  end
end
