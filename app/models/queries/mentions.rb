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
      return [] if @query.length < 2
      users
    end

    private

    def users
      @users = Queries::Elastic::Mentions.search(@query, profile_id: @profile_id).records(['users.id <> ?', @current_user.id])
    end
  end
end
