class AuthenticationManager < BaseManager
  attr_reader :email, :password, :password_confirmation, :first_name, :last_name

  EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  # @param email [String]
  # @param password [String]
  # @param password_confirmation [String]
  # @param first_name [String]
  # @param last_name [String]
  def initialize(email: nil, password: nil, password_confirmation: nil, first_name: nil, last_name: nil)
    @email = email.to_s
    @password = password
    @password_confirmation = password_confirmation
    @first_name = first_name.try(:humanize)
    @last_name = last_name.try(:humanize)
  end

  # @return [User]
  def authenticate
    fail_with! :email    unless email_taken?
    fail_with! :password unless user.password_hash == password_hash
    user
  end

  # @return [User]
  def register
    validate! do
      fail_with first_name: :empty if first_name.blank?
      fail_with last_name: :empty if last_name.blank?

      fail_with email: :empty if email.blank?
      fail_with :email unless email.match(EMAIL_REGEXP)
      fail_with email: :taken if email_taken?

      if password.to_s.length < 5
        fail_with password: {too_short: {minimum: 5}}
      else
        fail_with password_confirmation: :does_not_match_password if password_confirmation != password
      end
    end

    user.email = email
    user.full_name = "#@first_name #@last_name"

    user.password_salt = BCrypt::Engine.generate_salt
    user.password_hash = password_hash

    user.save or fail_with! user.errors
    user
  end

  private

  def email_taken?
    !user.new_record?
  end

  def user
    @user ||= User.where(email: email).first || User.new(email: email)
  end

  # @return [String]
  def password_hash
    BCrypt::Engine.hash_secret(password, user.password_salt)
  end
end