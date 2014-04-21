module Queries
  class ProfileTypes

    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil)
      @query = query.to_s
      @user = user or raise ArgumentError, 'User is not set'
    end

    # @return [Array<ActiveRecord::Base>]
    def results
      @results ||= begin
        user_profile_type_ids = @user.profile_types.pluck(:id)
        ProfileType.search_by_title(@query).limit(10).where.not(id: user_profile_type_ids).to_a
      end
    end
  end
end
