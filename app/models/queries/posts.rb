module Queries
  class Posts

    # @param user [User]
    # @param query [String, nil]
    # @param start_id [Integer, nil]
    def initialize(user: nil, query: nil, start_id: nil)
      @user = user
      @query = query
      @start_id = start_id
    end
    
    # @return [Array<Post>]
    def results
      @results ||= begin
        posts = autocomplete? ? matching_posts : recent_posts
        posts = posts.where(['id < ?', @start_id]) if @start_id.present?
        posts
      end.to_a
    end

    def autocomplete?
      @query.present?
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

    def matching_posts
      @user.posts.search_by_message(@query).limit(10)
    end

    def recent_posts
      @user.posts.recent
    end
  end
end