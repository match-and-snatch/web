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
      Day.new(day: day, pending_payments: pending_payments, payments: payments)
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
    month  = Time.zone.now.prev_month
    start  = month.beginning_of_month
    finish = month.end_of_month
    @pending_payments ||= {}.tap do |pending_payments|
      user.source_subscriptions.
          not_removed.
          not_rejected.
          where(charged_at: start..finish).
          group_by { |s| s.charged_at.next_month.to_date }.each do |date, subscriptions|
        pending_payments[date] = subscriptions.count
      end
    end
  end

  def payments
    @payments ||= {}.tap do |payments|
      user.source_payments.
          where(created_at: date_time_period).
          group_by { |p| p.created_at.to_date }.each do |date, asd|
        payments[date] = asd.count
      end
    end
  end

  class Day
    attr_reader :day, :pending_payments, :payments

    def initialize(day: , pending_payments: , payments:)
      @day = day
      @pending_payments = pending_payments
      @payments = payments
    end

    def name
      day.strftime('%b %d')
    end

    def date
      day.to_time.to_i
    end

    def pending_payments_count
      pending_payments[day] || 0
    end

    def payments_count
      payments[day] || 0
    end
  end
end
