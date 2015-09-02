module Concerns::EmailValidator
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,4})\z/i

  def validate_email(email, check_if_taken: true, field_name: :email)
    return fail_with field_name => :empty if email.blank?
    return fail_with field_name unless email.match(EMAIL_REGEXP)

    if check_if_taken
      return fail_with field_name => :taken if email_taken?(email)
    end
  end

  def email_taken?(email = nil)
    User.by_email(email).where('activated =? OR is_admin = ?', true, true).any?
  end
end
