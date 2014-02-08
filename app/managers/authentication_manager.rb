class AuthenticationManager < BaseManager
  attr_reader :email, :password, :slug, :login

  EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  # @param email [String]
  # @param password [String]
  # @param login [String]
  def initialize(email: nil, password: nil, login: nil)
    @email    = email
    @password = password
    @login    = login
    @slug     = @login.to_s.parameterize
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
      fail_with login: 'cannot be empty'                         if login.blank?
      fail_with login: 'can contain only characters and numbers' if login != slug
      fail_with login: 'already taken'                           if slug_taken?

      fail_with email: 'cannot be empty' if email.blank?
      fail_with :email unless email.match(EMAIL_REGEXP)
      fail_with email: 'already taken'   if email_taken?

      fail_with password: 'please enter at least 5 characters' if password.to_s.length < 5
    end

    user.slug  = slug
    user.email = email

    user.password_salt = BCrypt::Engine.generate_salt
    user.password_hash = password_hash

    user.save or fail_with! user.errors
    user
  end

  private

  def email_taken?
    !user.new_record?
  end

  def slug_taken?
    User.where(slug: slug).any?
  end

  def user
    @user ||= User.where(email: email).first || User.new(email: email)
  end

  # @return [String]
  def password_hash
    BCrypt::Engine.hash_secret(password, user.password_salt)
  end
end