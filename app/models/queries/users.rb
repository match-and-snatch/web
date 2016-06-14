module Queries
  class Users < BaseQuery
    EMAIL_REGEX = /\A[^@\s]+@([^@\s\.]+\.)+[^@\s\.]+\z/i
    INTEGER_RANGE_LIMIT = 2147483647

    # @param query [String]
    # @param user [User] current user performing the query
    def initialize(query: '', user: nil, include_hidden: false)
      @query = query.to_s.strip[0..40]
      @include_hidden = include_hidden
      @user = user or raise ArgumentError, 'User is not set'
    end

    # @return [Array<ActiveRecord::Base>]
    def by_admin_fields
      result = case @query
      when -> (q) { /^cus_/.match(q) && q.length == 18 }
        User.where(stripe_user_id: @query)
      when /@/
        User.by_email(@query)
      when /^\d+$/
        raise ArgumentError, 'id is too long' if @query.to_i > INTEGER_RANGE_LIMIT
        User.where(id: @query)
      else
        Queries::Elastic::Users.new.search(@query).records
      end

      limit(result, 20)
    end

    # Returns users by email
    # @return [Array<ActiveRecord::Base>]
    def by_email
      @results ||= begin
        User.by_email(emails).limit(200).order(:full_name).to_a
      end
    end

    # @return [ActiveRecord::Relation]
    def by_first_letter
      letter = @query[0] || 'A'

      if letter.include?('0')
        base_query.where("users.profile_name SIMILAR TO '[0-9]%'")
      elsif letter.include?('~')
        base_query.where("users.profile_name SIMILAR TO '[^0-9a-zA-Z]%'")
      else
        base_query.where(['users.profile_name ILIKE ?', "#{letter}%"])
      end.order(:profile_name)
    end

    # @return [Hash<String, Array>]
    def grouped_by_first_letter
      {}.tap do |result|
        ('A'..'Z').each do |letter|
          result[letter] ||= []
        end

        result.merge!(base_query.
                        where(has_public_profile: false).
                        order('LOWER(profile_name)').
                        limit(4000).
                        group_by { |user| user.name[0].upcase })

        result['0-9'] = []

        ('0'..'9').each do |number|
          if number_group = result.delete(number)
            result['0-9'].concat(number_group)
          end
        end

        boortz = User.where(registration_token: 'EPrIZ_8bLkzOhBmE5Lor6Q').first
        result['B'].unshift(boortz) if boortz
      end
    end

    # Used for autocomplete in user messaging
    # @return [Array<ActiveRecord::Base>]
    def by_name
      limit(Queries::Elastic::Users.new.search(@query).records, 20)
    end

    # @param user [User] Potential subordinate account
    # @return [Array<ActiveRecord::Base>]
    def potential_partners(user)
      by_admin_fields.reject { |u| u.id == user.id }
    end

    # Returns 5 best matches from profiles set
    # @return [Array<ActiveRecord::Base>]
    def profile_owners_by_text
      case @query.length
      when 0, 1
        User.none
      else
        limit(Queries::Elastic::Profiles.new.search(@query, include_hidden: @include_hidden).records, 5)
      end
    end

    private

    # @return [ActiveRecord::Relation]
    def base_query
      result = User.respectable
      result = result.where(hidden: false) unless @include_hidden
      result
    end

    # @return [Array<String>]
    def emails
      (@query.split(/[ ,]+/) - [@user.email]).keep_if do |email|
        email =~ EMAIL_REGEX
      end
    end
  end
end
