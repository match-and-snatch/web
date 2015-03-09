class CurrentMonthPresenter
  attr_reader :user

  def initialize(user: nil)
   @user = user
  end

  def each_day(&block)
    collection.each(&block)
  end

  def collection
    period.map do |day|
      Day.new(date: day, pending_payments: pending_payments, payments: payments)
    end
  end

  private

  def period
    Date.current.beginning_of_month..Date.current.end_of_month
  end

  def date_time_period
    Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
  end

  def pending_payments
    @pending_payments ||= {}.tap do |pending_payments|
      user.source_subscriptions.
          where(charge_date: date_time_period, removed: false, rejected: false).
          group('DATE(charge_date)').count.each do |date, count|
        pending_payments[date] = count
      end
    end
  end

  def payments
    @payments ||= {}.tap do |payments|
      user.source_payments.
          where(created_at: date_time_period).
          group('DATE(created_at)').count.each do |date, count|
        payments[date] = count
      end
    end
  end

  class Day
    attr_reader :date, :pending_payments, :payments

    def initialize(date: , pending_payments: , payments:)
      @date = date
      @pending_payments = pending_payments
      @payments = payments
    end

    def name
      date.strftime('%b %d')
    end

    def pending_payments_count
      pending_payments[date] || 0
    end

    def payments_count
      payments[date] || 0
    end
  end
end
