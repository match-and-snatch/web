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

  # @param token [String]
  # @return [User]
  def activate(token)
    user = User.where(registration_token: token).first or fail_with!(:invalid_token)
    user.activated = true
    user.save!
    user
  end

  # @return [User]
  def authenticate
    _user = nil

    User.by_email(email).find_each do |user|
      begin
        _user = User.by_email(email).where(password_hash: user.generate_password_hash(password)).first
      rescue BCrypt::Errors::InvalidSalt
        next
      end
    end

    _user or raise AuthenticationError.new(message: t(:invalid_login))
    _user
  end

  # @return [User]
  def register
    validate! { validate_input }

    user.is_profile_owner = is_profile_owner
    user.full_name = full_name
    user.email = email
    user.set_new_password(password)
    user.generate_auth_token
    user.generate_registration_token

    user.save or fail_with! user.errors
    AuthMailer.delay.registered(user)
    user
  end

  def restore_password
    user = User.by_email(email).first

    validate! do
      fail_with email: :empty if email.blank?
      fail_with :email unless email.match(EMAIL_REGEXP)
    end
    fail_with! email: :no_such_email unless user

    user.generate_password_reset_token!
    AuthMailer.delay.forgot_password(user)
  end

  # @return [User]
  def change_password
    user = User.by_email(email).first

    fail_with! token: :empty if user.password_reset_token.blank?

    validate! do
      validate_password password:              password,
                        password_confirmation: password_confirmation
    end

    user.set_new_password(password)
    user.password_reset_token = nil
    user.save or fail_with! user.errors
    user
  end

  def valid_input?
    validate_input
    valid?
  end

  private

  def email_taken? _=nil
    !user.new_record?
  end

  def user
    @user ||= User.by_email(email).where(activated: true).first || User.new(email: email)
  end

  def validate_input
    if full_name.blank?
      fail_with full_name: :empty
      fail_with first_name: :empty
      fail_with last_name: :empty
    elsif first_name.present? || last_name.present?
      fail_with first_name: :empty if first_name.blank?
      fail_with last_name: :empty if last_name.blank?
    end

    validate_email(email)
    validate_password(password: password, password_confirmation: password_confirmation)
  end
end
