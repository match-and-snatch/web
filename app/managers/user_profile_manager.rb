class UserProfileManager < BaseManager
  attr_reader :user

  SLUG_REGEXP = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
  ONLY_DIGITS = /^[0-9]*$/i

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param subscription_cost [Float, String]
  # @param slug [String]
  # @return [User]
  def update(subscription_cost: nil, slug: nil)
    slug = slug.try(:strip)

    validate! do
      if subscription_cost.blank?
        fail_with subscription_cost: 'must be set'
      else
        fail_with subscription_cost: 'cannot be zero' if subscription_cost.to_f.zero?
      end

      fail_with slug: 'cannot be empty' if slug.blank?
      fail_with slug: 'must contain only a-z characters and dashes' unless slug.match SLUG_REGEXP
      fail_with slug: 'is already taken' if slug_taken?(slug)
    end

    user.subscription_cost = subscription_cost
    user.slug = slug
    user.save or fail_with! user.errors
    user
  end

  # @param holder_name [String]
  # @param routing_number [String]
  # @param account_number [String]
  # @return [User]
  def update_payment_information(holder_name: nil, routing_number: nil, account_number: nil)
    holder_name    = holder_name.to_s.strip
    routing_number = routing_number.to_s.strip
    account_number = account_number.to_s.strip

    validate! do
      fail_with holder_name: 'cannot be empty' if holder_name.blank?

      if routing_number.match ONLY_DIGITS
        fail_with routing_number: 'must contain 9 digits' if routing_number.try(:length) != 9
      else
        fail_with routing_number: 'must contain only digits'
      end

      if account_number.match ONLY_DIGITS
        fail_with account_number: 'must contain 12 digits' if account_number.try(:length) != 12
      else
        fail_with account_number: 'must contain only digits'
      end
    end

    user.holder_name    = holder_name
    user.routing_number = routing_number
    user.account_number = account_number

    user.save or fail_with! user.errors
    user
  end

  private

  # @param slug [String]
  def slug_taken?(slug)
    User.where.not(id: user.id).where(slug: slug).any?
  end
end