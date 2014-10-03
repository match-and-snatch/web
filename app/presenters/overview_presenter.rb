class OverviewPresenter

  def total_subscribers_count
    Subscription.count
  end

  def total_active_subscribers_count
    Subscription.where(removed: false).count
  end

  def total_unsubscribers_count
    Subscription.where(removed: true).count
  end

  def total_failed_payments_count
    User.where(billing_failed: true).count
  end

  def total_gross_sales
    Payment.sum(:amount)
  end

  def total_connectpal_fees
    Payment.sum(:subscription_fees) - self.stripe_fees
  end

  def total_tos_fees
    Subscription.where(removed: true).sum(:cost)
  end

  def stripe_fees
    Payment.count * 30 + Payment.sum(:amount) * 0.029
  end

  def daily_payments
    Payment.where(created_at: current_day)
  end

  def daily_gross_sales
    self.daily_payments.sum(:amount)
  end

  def daily_subscribers_count
    Subscription.where(created_at: current_day).count
  end

  def daily_unsubscribers
    Subscription.where(removed_at: current_day)
  end

  def daily_unsubscribers_count
    self.daily_unsubscribers.count
  end

  def daily_failed_payments_count
    User.joins(:payment_failures).where(payment_failures: { created_at: current_day }).select('users.id').uniq.count
  end

  def daily_tos_fees
    self.daily_unsubscribers.sum(:cost)
  end

  def daily_stripe_fees
    self.daily_payments.count * 30 + daily_gross_sales * 0.029
  end
  
  private
  
  def current_day
    Time.zone.now.beginning_of_day..Time.zone.now.end_of_day
  end
end
