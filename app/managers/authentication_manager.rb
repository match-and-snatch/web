class AuthenticationManager < BaseManager
  include Concerns::EmailValidator
  include Concerns::PasswordValidator

  attr_reader :is_profile_owner, :email, :password, :password_confirmation, :first_name, :last_name, :full_name

  # @param email [String]
  # @param password [String]
  # @param password_confirmation [String]
  # @param first_name [String]
  # @param last_name [String]
  def initialize(is_profile_owner: false,
                 email: nil,
                 password: nil,
                 password_confirmation: nil,
                 full_name: nil,
                 first_name: nil,
                 last_name: nil)
    @is_profile_owner      = is_profile_owner
    @email                 = email.to_s
    @password              = password
    @password_confirmation = password_confirmation
    @first_name            = first_name.try(:humanize)
    @last_name             = last_name.try(:humanize)
    @full_name             = full_name || "#@first_name #@last_name"
  end

  # @return [User]
  def authenticate
    fail_with! :email    unless email_taken?(email)
    fail_with! :password unless user.password_hash == user.generate_password_hash(password)
    user
  rescue ManagerError
    raise AuthenticationError.new(message: t(:invalid_login))
  end

  # @return [User]
  def register
    validate! { validate_input }

    user.is_profile_owner = is_profile_owner
    user.full_name = full_name
    user.email = email
    user.set_new_password(password)
    user.generate_auth_token

    user.save or fail_with! user.errors
    user
  end

  def valid_input?
    validate_input
    valid?
  end

  private

  def email_taken? _
    !user.new_record?
  end

  def user
    @user ||= User.where(email: email).first || User.new(email: email)
  end

  def validate_input
    if full_name.blank?
      fail_with full_name: :empty
    elsif first_name.present? || last_name.present?
      fail_with first_name: :empty if first_name.blank?
      fail_with last_name: :empty if last_name.blank?
    end

    validate_email(email)
    validate_password(password: password, password_confirmation: password_confirmation)
  end
end
