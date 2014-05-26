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
    def by_name
      User.search_by_text_fields(@query).limit(20).to_a
    end

    def profile_owners_by_text
      case @query.length
      when 0, 1
        User.none
      when 2
        User.profile_owners.
          with_complete_profile.
          where(['users.profile_name ILIKE ?', "%#@query%"]).
          where.not(profile_picture_url: nil).
          limit(5).
          order('subscribers_count DESC')
      else
        User.profile_owners.
          with_complete_profile.
          search_by_text_fields(@query).
          where.not(profile_picture_url: nil).
          limit(5)
      end
    end

    # @return [Array<ActiveRecord::Base>]
    def results
      @results ||= begin
        User.by_email(emails).limit(200).order(:full_name).to_a
      end
    end

    def by_email
      results
    end

    def emails
      (@query.split(/[ ,]+/) - [@user.email]).keep_if do |email|
        email =~ EMAIL_REGEX
      end
    end
  end
end
