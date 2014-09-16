module Concerns::PaymentEventsTracker
  # @param user [User]
  def payment_created(user: )
    Event.create! user: user, action: 'payment_created'
  end

  # @param user [User]
  def payment_failed(user: )
    Event.create! user: user, action: 'payment_failed'
  end
end