class CurrentMonthPresenter
  attr_reader :user

  def initialize(user: nil)
   @user = user
  end

  def each_day(&block)
    collection.each(&block)
  end

  def collection
    current_day = Date.current
    @collection ||= (current_day.beginning_of_month..current_day.end_of_month).map do |day|
      Day.new(day: day,
              pending_payments: pending_payments,
              success_payments: success_payments,
              failed_payments: failed_payments)
    end
  end

  def total_pending_payments_count
    pending_payments.values.sum
  end

  def total_delayed_payments_count
    collection.sum(&:delayed_payments_count)
  end

  def total_failed_payments_count
    failed_payments.values.sum
  end

  def total_success_payments_count
    success_payments.values.sum
  end

  private

  def period
    current_time = Time.zone.now
    current_time.beginning_of_month..current_time.end_of_month
  end

  def pending_payments
    month  = Time.zone.now.prev_month
    start  = month.beginning_of_month
    finish = month.end_of_month

    @out_of_period_pending_count ||= user.source_subscriptions.
                                       not_removed.
                                       not_rejected.
                                       where(['charged_at < ?', start]).count

    @pending_payments ||= {}.tap do |pending_payments|
      user.source_subscriptions.
        not_removed.
        not_rejected.
        where(charged_at: start..finish).
        group_by { |s| s.billing_date }.each do |date, subscriptions|
          pending_payments[date] = subscriptions.count + @out_of_period_pending_count
      end
    end
  end

  def success_payments
    @success_payments ||= {}.tap do |success_payments|
      user.source_payments.
        where(created_at: period).
        group_by { |p| p.created_at.to_date }.each do |date, payments|
        success_payments[date] = payments.count
      end
    end
  end

  def failed_payments
    @failed_payments ||= {}.tap do |failed_payments|
      user.source_subscriptions.
        not_removed.
        where(rejected: true).
        where(rejected_at: period).
        group_by { |p| p.rejected_at.try(:to_date) }.each do |date, payments|
        failed_payments[date] = payments.count
      end
    end

    @failed_payments[:out_of_period_failed_count] ||= user.source_subscriptions.
                                                        not_removed.
                                                        where(rejected: true).
                                                        where(['rejected_at < ?', period.begin]).count

    @failed_payments
  end

  class Day
    attr_reader :day,
                :pending_payments,
                :success_payments,
                :failed_payments

    def initialize(day: , pending_payments: , success_payments: , failed_payments: )
      @day = day
      @pending_payments = pending_payments
      @success_payments = success_payments
      @failed_payments = failed_payments
    end

    def name
      day.strftime('%b %d')
    end

    def date
      day.to_time.to_i
    end

    def current_day?
      day == Date.current
    end

    def pending_payments_count
      (pending_payments[day] || 0) + failed_payments_count + failed_payments[:out_of_period_failed_count]
    end

    def success_payments_count
      success_payments[day] || 0
    end

    def failed_payments_count
      count = 0
      day.beginning_of_month.upto(day) do |_day|
        count += failed_payments[_day] || 0
      end
      count
    end

    def delayed_payments_count
      end_date = [day, Date.current].min

      day.beginning_of_month.upto(end_date).inject(0) do |count, _day|
        count + pending_payments[_day].to_i
      end
    end
  end
end
