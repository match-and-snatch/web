class PaymentsMailer < ApplicationMailer
  def failed(payment_failure)
    @payment_failure = payment_failure
    @user = payment_failure.user
    mail to: @user.email, subject: "Your payment has failed"
  end
end
