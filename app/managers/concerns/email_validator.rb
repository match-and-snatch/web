module Concerns::EmailValidator
  EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  def validate_email(email)
    fail_with email: :empty if email.blank?
    fail_with :email unless email.match(EMAIL_REGEXP)
    fail_with email: :taken if email_taken?(email)
  end

  def email_taken?(email = nil)
    User.where(email: email).any?
  end
end
