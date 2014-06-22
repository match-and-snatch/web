class UserStatsDecorator < UserDecorator
  delegate :full_name, to: :object

  def graph_data
    @graph_data ||= [].tap do |result|
      count = nil
      period.each_with_index do |date, day|
        count = events[date]
        result << {x: date.to_time.utc.beginning_of_day.to_i, y: count || 0}
      end
    end
  end

  def monthly_earnings
    @monthly_earnings ||= subscriptions_count * (object.cost || 0)
  end

  def profile_created
    object.created_at.to_date.to_s(:long)
  end

  def profile_types
    object.profile_types.map(&:title).join(' / ')
  end

  def subscribed_ever_count
    SubscribedFeedEvent.where(target_user_id: object.id).count
  end

  def subscriptions_count
    @subscriptions_count ||= subscriptions.count
  end

  def total_paid_out
    0
  end

  def total_and_tos
    0
  end

  def unsubscribed_ever_count
    UnsubscribedFeedEvent.where(target_user_id: object.id).count
  end

  def uploaded_bytes
    object.source_uploads.sum(:filesize)
  end

  private

  def end_date
    Time.zone.now.to_date
  end

  def events
    @events ||= {}.tap do |result|
      SubscriptionDailyCountChangeEvent.where(created_on: period, user_id: object.id).order(:created_on).find_each do |event|
        result[event.created_on] = event.subscriptions_count
      end
    end
  end

  def period
    (start_date..end_date)
  end

  def start_date
    [Time.zone.now.to_date - 30.days, SubscriptionDailyCountChangeEvent.order(:created_on).first.try(:created_on), object.created_at.to_date].compact.max - 1.day
  end

  def subscriptions
    Subscription.not_removed.joins(:user).where({users: {billing_failed: false}}).where(target_user_id: object.id)
  end
end
