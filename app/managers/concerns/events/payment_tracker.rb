module Concerns::Events::PaymentTracker
  # @param user [User]
  # @param payment [Payment]
  def payment_created(user: , payment: )
    Event.create! user: user,
                  action: 'payment_created',
                  data: { amount: payment.amount,
                          cost: payment.user_cost,
                          subscription_cost: payment.user_subscription_cost,
                          subscription_fees: payment.user_subscription_fees,
                          target_user_id: payment.target_user_id,
                          target_id: payment.target_id,
                          target_type: payment.target_type,
                          payment_id: payment.id }
  end

  # @param user [User]
  # @param payment_failure [PaymentFailure]
  def payment_failed(user: , payment_failure: )
    Event.create! user: user,
                  action: 'payment_failed',
                  data: { failure_id: payment_failure.id,
                          target_user_id: payment_failure.target_user_id,
                          target_id: payment_failure.target_id,
                          target_type: payment_failure.target_type }
  end
end