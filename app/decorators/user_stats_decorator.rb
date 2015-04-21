class UserStatsDecorator < UserDecorator
  delegate :full_name, to: :object

  def fake_subscriptions_count
    @fake_subscriptions_count ||= object.source_subscriptions.where(fake: true, removed: false).count
  end

  def fakes_count
    count = fake_subscriptions_count
    "#{count} ($#{count * object.cost / 100.0})"
  end

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
    @monthly_earnings ||= subscriptions.sum(:cost)
  end

  def profile_created
    object.created_at.to_date.to_s(:long)
  end

  def profile_types
    object.profile_types.map(&:title).join(' / ')
  end

  # @return [Integer]
  def subscribed_ever_count
    Subscription.where(target_user_id: object.id).count
  end

  def unsubscribed_ever_count
    removed_subscriptions.count
  end

  def uploaded_bytes
    object.source_uploads.sum(:filesize)
  end

  def total_gross
    payments.sum(:amount)
  end

  def total_subscription_sales
    payments.sum(:cost)
  end

  def connectpal_fee
    payments.sum(:subscription_fees)
  end

  def tos_fee
    removed_subscriptions.sum(:cost)
  end

  def stripe_fee
    payments.count * 30 + payments.sum(:amount) * 0.029
  end

  def total_paid_out
    StripeTransfer.where(user_id: object.id).sum(:amount)
  end

  # @return [Integer]
  def connectpal_and_tos
    Payment.where(target_user_id: object.id).sum(:subscription_fees) + removed_subscriptions.sum(:cost)
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

  def payments
    @payments ||= Payment.where(target_user_id: object.id)
  end

  def removed_subscriptions
    Subscription.where(target_user_id: object.id, removed: true)
  end
end
