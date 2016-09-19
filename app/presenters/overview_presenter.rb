class OverviewPresenter

  def current_subscribers_count
    subscriptions.not_removed.not_rejected.count
  end

  def total_subscribers_count
    subscriptions.count
  end

  def current_unsubscribers_count
    subscriptions.where(['removed = ? OR rejected = ?', true, true]).count
  end

  def current_failed_payments_count
    User.where(billing_failed: true).count
  end

  def total_gross_sales
    @total_gross_sales ||= Payment.sum(:amount)
  end

  def total_subscription_sales
    @total_subscription_sales ||= Payment.sum(:cost)
  end

  def total_connectpal_fees
    Payment.sum(:subscription_fees) - self.total_stripe_fees
  end

  def total_tos_fees
    subscriptions.where(removed: true).sum(:cost)
  end

  def total_stripe_fees
    @total_stripe_fees ||= Payment.count * 30 + self.total_gross_sales * stripe_percent
  end

  # Daily stats section is deprecated. Used only for console access.

  def daily_gross_sales
    @daily_gross_sales ||= daily_payments.sum(:amount)
  end

  def daily_tos_fees
    daily_unsubscribers.sum(:cost)
  end

  def daily_stripe_fees
    daily_payments.count * 30 + daily_gross_sales * stripe_percent
  end

  def daily_subscribers_count
    subscriptions.not_removed.where(created_at: current_day).count
  end

  def daily_total_subscribers_count
    events.where(action: 'subscription_created', created_at: current_day).count
  end

  def daily_unsubscribers_count
    daily_unsubscribers.count
  end

  def daily_total_unsubscribers_count
    events.where(action: 'subscription_canceled', created_at: current_day).count
  end

  def daily_failed_payments_count
    events.where(action: 'payment_failed', created_at: current_day).count
  end

  def daily_new_subscriptions_revenue
    subscriptions.joins(:payments)
      .where(subscriptions: {created_at: current_day})
      .sum('payments.amount')
  end

  def daily_recurring_subscriptions_revenue
    subscriptions.joins(:payments)
      .where(payments: {created_at: current_day})
      .where('subscriptions.created_at < ?', current_day.first)
      .sum('payments.amount')
  end

  def daily_contributions_revenue
    Contribution.where(created_at: current_day).sum(:amount)
  end

  private

  def daily_payments
    @daily_payments ||= Payment.where(created_at: current_day)
  end

  def daily_unsubscribers
    @daily_unsubscribers ||= subscriptions.where(removed_at: current_day)
  end

  def current_day
    Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
  end

  def stripe_percent
    BigDecimal.new(APP_CONFIG['stripe_percent'].to_s)
  end

  def subscriptions
    Subscription.base_scope
  end

  def events
    Event.base_scope
  end
end
