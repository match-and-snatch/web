class SubscriptionDecorator < BaseDecorator
  attr_reader :subscription, :date

  delegate :id, :user, :created_at, :removed_at, :charged_at, :billing_date, to: :subscription

  def initialize(subscription, current_date = nil)
    @subscription = subscription
    @date = current_date || Time.zone.today
    super()
  end

  def new?
    subscription.created_at + 1.month > date
  end

  def next_billing_date
    (date.beginning_of_month + subscription.created_at.day.days).to_date.to_s(:long)
  end
end