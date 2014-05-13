module Queries
  class Posts

    # @param user [User]
    # @param query [String, nil]
    # @param start_id [Integer, nil]
    def initialize(user: nil, current_user: user, query: nil, start_id: nil)
      @user = user
      @current_user = current_user
      @query = query
      @start_id = start_id
    end
    
    # @return [Array<Post>]
    def results
      @results ||= begin
        posts = @query.present? ? matching_posts : recent_posts
        posts = posts.where(['id < ?', @start_id]) if @start_id.present?

        if @user != @current_user
          posts = posts.where(hidden: false)
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
      @query.split(/\W+/).map(&:singularize).map(&:camelize).map { |x| x << 'Post' } & %w(AudioPost VideoPost PhotoPost DocumentPost StatusPost)
    end

    def matching_posts
      if tagged?
        @user.posts.where(type: types).order('created_at DESC, id DESC')
      else
        @user.posts.search_by_message(@query).limit(10)
      end
    end

    def recent_posts
      @user.posts.recent
    end
  end
end