class SubscriptionDecorator < BaseDecorator
  attr_reader :subscription, :date

  delegate :id, :user, :created_at, to: :subscription

  def initialize(subscription, current_date = nil)
    @subscription = subscription
    @date = current_date || Time.zone.today
    super()
  end

  def new?
    subscription.created_at + 1.month > date
  end
end