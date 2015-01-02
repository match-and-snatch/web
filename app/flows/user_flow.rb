class UserFlow < Flow

  # @overload
  def initialize(performer: User.new, subject: nil, parent: nil)
    super
  end

  factory do
    vattr(:password).require.password
    vattr(:password_confirmation).require.equal_to -> { password }

    attr(:email).require.email.uniq
    attr(:password_salt).map_to -> { BCrypt::Engine.generate_salt }
    attr(:password_hash).map_to -> { BCrypt::Engine.hash_secret(password, password_salt) }
    attr(:auth_token).map_to -> { User.generate_auth_token }
    attr(:registration_token).map_to -> { User.generate_registration_token }
  end
end