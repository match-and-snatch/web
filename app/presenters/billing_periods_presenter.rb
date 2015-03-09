class BillingPeriodsPresenter
  include Enumerable

  attr_reader :user

  # @param user [User]
  def initialize(user: nil)
    @user = user
  end

  def each(&block)
    collection.each(&block)
  end

  def collection
    periods.map do |period|
      BillingPeriod.new(user: user, period: period)
    end
  end

  private

  def periods
    first_month_date = @user.created_at.beginning_of_month
    last_month_date = first_month_date.end_of_month

    result = [(first_month_date..last_month_date)]

    while first_month_date.month != Time.zone.now.month
      first_month_date += 1.month
      last_month_date = first_month_date.end_of_month
      result << (first_month_date..last_month_date)
    end

    result
  end

  class BillingPeriod

    def initialize(user: nil, period: nil)
      @user = user
      @period = period
    end

    def end_date
      @period.end.to_s
    end

    def name
      Date::MONTHNAMES[@period.begin.month]
    end

    def current?
      @period.cover? Time.zone.now
    end

    def total_gross
      payments.sum(:amount) #- stripe_fee
    end

    def total_subscription_sales
      payments.sum(:cost)
    end

    def connectpal_fee
      payments.sum(:subscription_fees) - stripe_fee
    end

    def stripe_fee
      payments.count * 30 + payments.sum(:amount) * 0.029
    end

    def tos_fee
      removed_subscriptions.sum(:cost)
    end

    def total_subscribed_count
      stats_entry.try(:subscriptions_count) || 0
    end

    def subscribed_count
      @user.source_subscriptions.where(created_at: @period).count
    end

    def unsubscribed_count
      stats_entry.try(:unsubscribers_count) || 0
    end

    def this_month_subscribers_unsubscribers_count
      (@user.source_subscriptions.where(created_at: @period, removed: true) | @user.source_subscriptions.where(created_at: @period, rejected: true)).count
    end

    def payout
      @payout ||= transfers.sum(:amount)
    end

    def billing_failed_count
      stats_entry.try(:failed_payments_count) || 0
    end

    def successful_payments_count
      payments.count
    end

    def pending_payments_count
      @user.source_subscriptions.not_removed.where(charge_date: @period, rejected: false).count
    end

    private

    def removed_subscriptions
      Subscription.where(target_user_id: @user.id, removed_at: @period, removed: true)
    end

    def transfers
      @transfers ||= StripeTransfer.where(user_id: @user.id).where(created_at: @period)
    end

    def payments
      @payments ||= Payment.where(target_user_id: @user.id, created_at: @period)
    end

    def stats_entry
      @stats_entry ||= @user.subscription_daily_count_change_events.where(created_at: @period).order(created_at: :desc).first
    end
  end
end
