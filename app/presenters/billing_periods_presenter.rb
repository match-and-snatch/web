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

    def name
      Date::MONTHNAMES[@period.begin.month]
    end

    def total_gross
      payments.sum(:amount) / 100.0
    end

    def connectpal_fee
      payments.sum(:user_subscription_fees) - stripe_fee
    end

    def stripe_fee
      payments.count * 0.30 + (payments.sum(:amount) * 0.029) / 100.0
    end

    def tos_fee
      unsubscribed_count * @user.cost
    end

    def total_subscribed_count
      Subscription.where(target_user_id: @user.id).where(["removed_at > ? OR removed = 'f'", @period.end]).where(['created_at <= ?', @period.end]).count
    end

    def subscribed_count
      Subscription.where(target_user_id: @user.id, created_at: @period).count
    end

    def unsubscribed_count
      Subscription.where(target_user_id: @user.id, removed_at: @period, removed: true).count
    end

    def payout
      @payout ||= transfers.sum(:amount) / 100.0
    end

    private

    def transfers
      @transfers ||= StripeTransfer.where(user_id: @user.id).where(created_at: @period)
    end

    def payments
      @payments ||= Payment.where(target_user_id: @user.id, created_at: @period)
    end
  end
end