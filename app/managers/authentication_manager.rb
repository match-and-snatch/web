class AuthenticationManager < BaseManager
  attr_reader :email, :password

  # @param email [String]
  # @param password [String]
  def initialize(email, password)
    @email = email
    @password = password
  end

  # @return [User]
  def authenticate
    fail_with! 'Email is incorrect' unless email_taken?
    user.tap do
      fail_with! 'Password is incorrect' unless user.password_hash == password_hash
    end
  end

  # @return [User]
  def register
    fail_with! "#@email is already taken" if email_taken?

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

  def user
    @user ||= User.where(email: email).first || User.new(email: email)
  end

  # @return [String]
  def password_hash
    BCrypt::Engine.hash_secret(password, user.password_salt)
  end
end