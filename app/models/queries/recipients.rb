module Queries
  class Recipients < BaseQuery
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
        limit(User.where(recipients_ids).where(['users.profile_name ILIKE ?', "%#@query%"]).order(subscribers_count: :desc), 5)
      else
        limit(Queries::Elastic::Users.new.search(@query).records(recipients_ids), 5)
      end
    end

    private

    def recipients_ids
      {}.tap do |data|
        t = Subscription.arel_table
        data[:id] ||= Subscription.where(t[:user_id].eq(@user.id).or(t[:target_user_id].eq(@user.id))).pluck(:user_id, :target_user_id).flatten.uniq - [@user.id]
      end
    end
  end
end
