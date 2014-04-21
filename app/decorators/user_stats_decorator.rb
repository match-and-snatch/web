class UserStatsDecorator < UserDecorator

  def subscriptions_count
    @subscriptions_count ||= subscriptions.count
  end

  def monthly_earnings
    @monthly_earnings ||= subscriptions_count * object.cost
  end

  def graph_data
    @graph_data ||= [].tap do |result|
      count = nil
      period.each_with_index do |date, day|
        count ||= events[date]
        result << {x: date.to_time.to_i, y: count || 0}
      end
    end
  end

  private

  def period
    (start_date..end_date)
  end

  def start_date
    [Time.zone.now.beginning_of_month.to_date, object.created_at.to_date].max - 1.day
  end

  def end_date
    Time.zone.now.to_date + 1.day
  end

  def events
    @events ||= {}.tap do |result|
      SubscriptionDailyCountChangeEvent.where(created_on: period, user_id: object.id).order(:created_on).find_each do |event|
        result[event.created_on] = event.subscriptions_count
      end
    end
  end

  def subscriptions
    Subscription.where(target_user_id: object.id)
  end
end