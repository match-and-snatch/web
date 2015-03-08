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
                 last_name: nil,
                 api_token: nil)
    @is_profile_owner      = is_profile_owner
    @email                 = email.to_s
    @password              = password
    @password_confirmation = password_confirmation
    @first_name            = first_name.strip.humanize if first_name
    @last_name             = last_name.strip.humanize if last_name
    @full_name             = full_name || "#@first_name #@last_name"
    @api_token             = api_token
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
  def authenticate(generate_api_token: false)
    user = User.by_email(email).first or raise AuthenticationError.new(errors: {email: t(:user_does_not_exist)})
    BCrypt::Password.new(user.password_hash) == password or raise AuthenticationError.new(errors: {password: t(:invalid_password)})

    user.generate_api_token! if generate_api_token
    EventsManager.user_logged_in(user: user)

    user
  end

  # @return [User]
  def authenticate_api
    @api_token or raise AuthenticationError.new(errors: {api_token: 'required'})
    User.where(api_token: @api_token).first or raise AuthenticationError.new(errors: {api_token: 'invalid'})
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
    AuthMailer.delay.registered(user) if user.is_profile_owner?
    EventsManager.user_registered(user: user)
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
    EventsManager.restore_password_requested(user: user)
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
    EventsManager.password_restored(user: user)
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
    #@user ||= User.by_email(email).where(activated: true).first || User.new(email: email)
    @user ||= User.by_email(email).first || User.new(email: email)
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
