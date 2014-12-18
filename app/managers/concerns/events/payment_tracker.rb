module Concerns::Events::PaymentTracker
  # @param user [User]
  # @param contribution [Contribution]
  # @yield
  # @return [Event]
  def contribution_created(user: , contribution: , &block)
    Event.create! user: user,
                  action: 'contribution_created',
                  data: { amount: contribution.amount,
                          user_id: contribution.user_id,
                          target_user_id: contribution.target_user_id,
                          parent_id: contribution.try(:parent_id),
                          contribution_id: contribution.id },
                  &block
  end

  # @param user [User]
  # @param contribution [Contribution]
  # @yield
  # @return [Event]
  def contribution_failed(user: , contribution: , &block)
    Event.create! user: user,
                  action: 'contribution_failed',
                  data: { amount: contribution.amount,
                          user_id: contribution.user_id,
                          target_user_id: contribution.target_user_id,
                          parent_id: contribution.try(:parent_id),
                          contribution_id: contribution.id },
                  &block
  end

  # @param user [User]
  # @param payment [Payment]
  # @yield
  # @return [Event]
  def payment_created(user: , payment: , &block)
    Event.create! user: user,
                  action: 'payment_created',
                  data: { amount: payment.amount,
                          cost: payment.cost,
                          subscription_cost: payment.subscription_cost,
                          subscription_fees: payment.subscription_fees,
                          target_user_id: payment.target_user_id,
                          target_id: payment.target_id,
                          target_type: payment.target_type,
                          payment_id: payment.id },
                  &block
  end

  # @param user [User]
  # @param payment_failure [PaymentFailure]
  # @yield
  # @return [Event]
  def payment_failed(user: , payment_failure: , &block)
    Event.create! user: user,
                  action: 'payment_failed',
                  data: { failure_id: payment_failure.id,
                          target_user_id: payment_failure.target_user_id,
                          target_id: payment_failure.target_id,
                          target_type: payment_failure.target_type },
                  &block
  end
end
