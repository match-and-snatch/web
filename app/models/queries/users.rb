module Queries
  class Users
    EMAIL_REGEX = /\A[^@\s]+@([^@\s\.]+\.)+[^@\s\.]+\z/i

    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil)
      @query = query.to_s
      @user = user or raise ArgumentError, 'User is not set'
    end

    # @return [Array<ActiveRecord::Base>]
    def results
      @results ||= begin
        User.where(email: emails).limit(200).order(:full_name).to_a
      end
    end

    def emails
      (@query.split(/[ ,]+/) - [@user.email]).keep_if do |email|
        email =~ EMAIL_REGEX
      end
    end
  end
end