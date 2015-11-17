module Queries
  class Mentions < BaseQuery
    # @param query [String]
    # @param current_user [User]
    # @param profile_id [String]
    def initialize(query: '', current_user: , profile_id: nil)
      @query = query.to_s
      @current_user = current_user
      @profile_id = profile_id.to_i
    end

    def by_name
      results = if @profile_id
                  if @current_user.id == @profile_id
                    users.merge!(users.joins(:subscriptions).where(subscriptions: { target_user_id: @profile_id }))
                  else
                    users.merge!(users.joins("LEFT OUTER JOIN subscriptions ON subscriptions.user_id = users.id")
                                      .where(["subscriptions.target_user_id = ? OR users.id = ?", @profile_id, @profile_id])
                                      .group("users.id"))
                  end
                else
                  users
                end
      limit(results, 5)
    end

    private

    def users
      @users = Queries::Elastic::Users.new.search(@query).relation(["users.id != ?", @current_user.id]).limit(5)
    end
  end
end
