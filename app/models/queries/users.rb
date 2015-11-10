module Queries
  class Users
    EMAIL_REGEX = /\A[^@\s]+@([^@\s\.]+\.)+[^@\s\.]+\z/i

    # @param query [String]
    # @param user [User]
    def initialize(query: '', user: nil, include_hidden: false)
      @query = query.to_s.strip[0..40]
      @include_hidden = include_hidden
      @user = user or raise ArgumentError, 'User is not set'
    end

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

    def by_first_letter
      letter = @query[0] || 'A'

      if letter.include?('0')
        base_query.where("users.profile_name SIMILAR TO '[0-9]%'")
      else
        base_query.where(['users.profile_name ILIKE ?', "#{letter}%"])
      end.order(:profile_name)
    end

    # @return [Array<ActiveRecord::Base>]
    def by_name
      limit_results(Queries::Elastic::Users.new.search(@query).records, limit: 20)
    end

    # @return [Array<ActiveRecord::Base>]
    def by_admin_fields
      result = case @query
      when -> (q) { /^cus_/.match(q) && q.length == 18 }
        User.where(stripe_user_id: @query)
      when /@/
        User.where(email: @query)
      when /^\d+$/
        User.where(id: @query)
      else
        Queries::Elastic::Users.new.search(@query).records
      end

      limit_results(result, limit: 20)
    end

    # @param user [User] Potential subordinate account
    def potential_partners(user)
      by_admin_fields.reject { |u| u.id == user.id }
    end

    def profile_owners_by_text
      case @query.length
      when 0, 1
        User.none
      else
        limit_results(Queries::Elastic::Profiles.new.search(@query).records, limit: 5)
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
      result = User.profile_owners
                   .with_complete_profile
                   .where('users.subscribers_count > 0 OR users.profile_picture_url IS NOT NULL')

      unless @include_hidden
        result = result.where(hidden: false)
      end

      result
    end

    def limit_results(results, limit: 5)
      if results.is_a?(Array)
        Kaminari.paginate_array(results).page.per(limit)
      elsif results.is_a?(ActiveRecord::Relation)
        results.limit(limit).to_a
      else
        raise ArgumentError, 'Invalid results collection'
      end
    end
  end
end
