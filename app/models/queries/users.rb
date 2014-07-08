module Queries
  class Users
    EMAIL_REGEX = /\A[^@\s]+@([^@\s\.]+\.)+[^@\s\.]+\z/i

    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil)
      @query = query.to_s
      @user = user or raise ArgumentError, 'User is not set'
    end

    def grouped_by_first_letter
      {}.tap do |result|
        ('A'..'Z').each do |letter|
          result[letter] ||= []
        end

        result.merge!(base_query.order('LOWER(profile_name)').limit(1000).group_by { |user| user.name[0].upcase })
        result['0-9'] = []

        ('0'..'9').each do |number|
          if number_group = result.delete(number)
            result['0-9'].concat(number_group)
          end
        end
      end
    end

    def by_first_letter
      letter = @query[0] || 'A'

      if letter.include?('0')
        base_query.where("users.profile_name SIMILAR TO '[0-9]%'")
      else
        base_query.where(['users.profile_name ILIKE ?', "#{letter}%"])
      end.order(:profile_name).limit(300)
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
        base_query.where(['users.profile_name ILIKE ?', "%#@query%"]).order('subscribers_count DESC').limit(5)
      else
        base.query.search_by_text_fields(@query).limit(5)
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

    private

    def base_query
      User.profile_owners.with_complete_profile.
        where('users.subscribers_count > 0 OR users.profile_picture_url IS NOT NULL')
    end
  end
end
