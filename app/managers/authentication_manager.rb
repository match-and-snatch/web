class AuthenticationManager < BaseManager
  include Concerns::EmailValidator
  include Concerns::PasswordValidator
  include Concerns::NameValidator

  attr_reader :is_profile_owner, :email, :password, :password_confirmation,
              :first_name, :last_name, :full_name, :tos_accepted

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
                 api_token: nil,
                 tos_accepted: false)
    @is_profile_owner      = is_profile_owner
    @email                 = email.to_s.downcase
    @password              = password
    @password_confirmation = password_confirmation
    @first_name            = first_name.strip.humanize if first_name
    @last_name             = last_name.strip.humanize if last_name
    @full_name             = full_name || "#@first_name #@last_name"
    @api_token             = api_token
    @tos_accepted          = tos_accepted
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
    user = user_by_email or raise AuthenticationError.new(errors: {email: t(:user_does_not_exist)})
    BCrypt::Password.new(user.password_hash) == password or raise AuthenticationError.new(errors: {password: t(:invalid_password)})

    user.generate_api_token! if generate_api_token
    EventsManager.user_logged_in(user: user)

    user
  end

  # @return [User]
  def authenticate_api
    @api_token.presence or raise AuthenticationError.new(errors: {api_token: 'required'})
    User.where(api_token: @api_token).first or raise AuthenticationError.new(errors: {api_token: 'invalid'})
  end

  # @return [User]
  def register
    validate! { validate_input }

    user.is_profile_owner = is_profile_owner
    user.full_name = full_name.try(:strip)
    user.email = email.try(:strip)
    user.set_new_password(password)
    user.generate_auth_token
    user.generate_registration_token

    user.save or fail_with! user.errors
    user.elastic_index_document
    EventsManager.user_registered(user: user)
    UserManager.new(user).mark_tos_accepted(accepted: true)
    user
  end

  def restore_password
    user = user_by_email

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
    user = user_by_email

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
    @user ||= user_by_email || User.new(email: email)
  end

  def user_by_email
    User.where(email: email).try_activated_one
  end

  def validate_input
    if full_name.blank?
      fail_with full_name: :empty
      fail_with first_name: :empty
      fail_with last_name: :empty
    elsif first_name.present? || last_name.present?
      validate_account_name(first_name, field_name: :first_name)
      validate_account_name(last_name, field_name: :last_name)
    end

    validate_email(email, email_confirmation: email)
    validate_password(password: password, password_confirmation: password_confirmation)

    fail_with tos_accepted: :not_accepted unless tos_accepted
  end
end
