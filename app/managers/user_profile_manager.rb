class UserProfileManager < BaseManager
  attr_reader :user

  SLUG_REGEXP  = /^[a-zA-Z0-9]+(\w|_|-)+[a-zA-Z0-9]+$/i
  EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/
  ONLY_DIGITS  = /^[0-9]*$/i

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
        fail_with subscription_cost: :empty
      else
        fail_with subscription_cost: :zero if subscription_cost.to_f.zero?
      end

      fail_with slug: :empty if slug.blank?
      fail_with slug: :not_a_slug unless slug.match SLUG_REGEXP
      fail_with slug: :taken if slug_taken?(slug)
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
      fail_with holder_name: :empty if holder_name.blank?

      if routing_number.match ONLY_DIGITS
        fail_with routing_number: :not_a_routing_number if routing_number.try(:length) != 9
      else
        fail_with routing_number: :not_an_integer
      end

      if account_number.match ONLY_DIGITS
        fail_with account_number: :not_an_account_number if account_number.try(:length) != 12
      else
        fail_with account_number: :not_an_integer
      end
    end

    user.holder_name    = holder_name
    user.routing_number = routing_number
    user.account_number = account_number

    user.save or fail_with! user.errors
    user
  end

  # @param full_name [String]
  # @param slug [String]
  # @param email [String]
  # @return [User]
  def update_general_information(full_name: nil, slug: nil, email: nil)
    validate! do
      fail_with full_name: :empty unless full_name.present?
      fail_with slug: :not_a_slug unless slug.match SLUG_REGEXP
      fail_with :email            unless email.match EMAIL_REGEXP
    end

    user.full_name = full_name
    user.slug = slug
    user.email = email

    user.save or fail_with! user.errors
    user
  end

  # @param current_password [String]
  # @param new_password [String]
  # @param new_password_confirmation [String]
  # @return [User]
  def change_password(current_password: nil, new_password: nil, new_password_confirmation: nil)
    AuthenticationManager.new(email: user.email, password: current_password, password_confirmation: current_password).authenticate

    validate! do
      if new_password.to_s.length < 5
        fail_with new_password: {too_short: {minimum: 5}}
      else
        fail_with new_password_confirmation: :does_not_match_password if new_password_confirmation != new_password
      end
    end

    user.set_new_password(new_password)
    user.save or fail_with! user.errors
    user
  rescue AuthenticationError
    fail_with! :current_password
  end

  private

  # @param slug [String]
  # @return [true, false]
  def slug_taken?(slug)
    User.where.not(id: user.id).where(slug: slug).any?
  end
end