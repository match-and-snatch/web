module Concerns::EmailValidator
  EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  def validate_email(email)
    return fail_with email: :empty if email.blank?
    return fail_with :email unless email.match(EMAIL_REGEXP)
    return fail_with email: :taken if email_taken?(email)
  end

  def email_taken?(email = nil)
    User.by_email(email).where(activated: true).any?
  end
end
