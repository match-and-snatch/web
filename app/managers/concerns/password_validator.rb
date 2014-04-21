module Concerns::PasswordValidator
  MINIMUM_PASSWORD_LENGTH = 5

  # @param password [Hash]
  # @param password_confirmation [Hash]
  # @param password_field_name [String]
  # @param password_confirmation_field_name [String]
  def validate_password(password: nil,
                        password_confirmation: nil,
                        password_field_name: :password,
                        password_confirmation_field_name: :password_confirmation)
    if password.to_s.length < MINIMUM_PASSWORD_LENGTH
      fail_with password_field_name => {too_short: {minimum: MINIMUM_PASSWORD_LENGTH}}
    elsif password != password_confirmation
      fail_with password_confirmation_field_name => :does_not_match_password
    end
  end
end
