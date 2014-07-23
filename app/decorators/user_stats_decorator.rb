class UserStatsDecorator < UserDecorator
  delegate :full_name, to: :object

  def target_subscriptions_count
    object.subscriptions.count
  end

  def removed_target_subscriptions_count
    object.subscriptions.where(removed: true).count
  end

  def target_subscriptions
    object.subscriptions
  end

  def target_sales
    object.payments.sum(:amount)
  end

  def failed_billing_users_count
    object.subscribers.where(billing_failed: true).count
  end

  def graph_data
    @graph_data ||= [].tap do |result|
      count = nil
      period.each do |date|
        count = events[date] || count || 0
        result << {x: date.to_time.utc.beginning_of_day.to_i, y: count}
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

  def subscriptions_count
    @subscriptions_count ||= subscriptions.count
  end

  def subscribed_ever_count
    Subscription.where(target_user_id: object.id).count
  end

  def unsubscribed_ever_count
    Subscription.where(target_user_id: object.id, removed: true).count
  end

  def uploaded_bytes
    object.source_uploads.sum(:filesize)
  end

  def total_gross
    payments.sum(:amount) / 100.0 #- stripe_fee
  end

  def total_paid_out
    StripeTransfer.where(user_id: object.id).sum(:amount) / 100.0
  end

  def connectpal_and_tos
    (Payment.where(target_user_id: object.id).sum(:user_subscription_fees) + unsubscribed_ever_count * object.subscription_cost.to_i)
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

  def payments
    @payments ||= Payment.where(target_user_id: object.id)
  end

  def stripe_fee
    payments.count * 0.30 + (payments.sum(:amount) * 0.027) / 100.0
  end
end
