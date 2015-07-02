module Queries
  class Recipients
    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil)
      @query = query.to_s
      @user = user or raise ArgumentError, 'User is not set'
    end

    def by_name
      case @query.length
      when 0, 1
        User.none
      when 2
        base_query.where(['users.profile_name ILIKE ?', "%#@query%"]).order('subscribers_count DESC').limit(5)
      else
        base_query.search_by_text_fields(@query).limit(5).to_a
      end
    end

    private

    def base_query
      t = Subscription.arel_table
      ids ||= Subscription.where(t[:user_id].eq(@user.id).or(t[:target_user_id].eq(@user.id))).pluck(:user_id, :target_user_id).flatten.uniq - [@user.id]
      User.where(id: ids)
    end
  end
end
