class AuthenticationManager < BaseManager
  attr_reader :email, :password, :slug, :login

  # @param email [String]
  # @param password [String]
  # @param login [String]
  def initialize(email: nil, password: nil, login: nil)
    @email    = email
    @password = password
    @login    = login
    @slug     = @login.to_s.parameterize if @login
  end

  # @return [User]
  def authenticate
    fail_with! :email    unless email_taken?
    fail_with! :password unless user.password_hash == password_hash
    user
  end

  # @return [User]
  def register
    fail_with! :login    if slug.empty?
    fail_with! :email    if email.blank?
    fail_with! :password if password.blank?

    fail_with! email: 'already taken' if email_taken?
    fail_with! login: 'already taken' if slug_taken?(slug)

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

  def slug_taken?(slug)
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