module Queries
  class SourceSubscriptions
    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil)
      @query = query.to_s
      @user = user or raise ArgumentError, 'User is not set'
    end

    def by_subscriber_name
      if @query.length.in?([0, 1])
        Subscription.none
      else
        base_query.where(['users.profile_name ILIKE ?', "%#@query%"]).order('subscribers_count DESC').limit(5)
      end
    end

    private

    def base_query
      @user.source_subscriptions.joins(:user)
    end
  end
end
