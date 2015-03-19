class UserStatsManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    @user = user
  end

  # Tracks changes in subscriptions count
  # Denormalizes into users table, saves stats in events
  # @return [SubscriptionDailyCountChangeEvent]
  def log_subscriptions_count
    subscriptions_count   = user.source_subscriptions.not_removed.where(rejected: false).count
    unsubscribers_count   = user.source_subscriptions.where(removed_at: current_month, removed: true).count
    failed_payments_count = user.source_subscriptions
                                .joins(:user)
                                .where(users: { billing_failed: true, billing_failed_at: current_month }).count

    user.subscribers_count = subscriptions_count
    save_or_die! user

    stat_entry = SubscriptionDailyCountChangeEvent.where(created_on: current_date, user_id: user.id).first

    if stat_entry
      stat_entry.subscriptions_count   = subscriptions_count
      stat_entry.unsubscribers_count   = unsubscribers_count
      stat_entry.failed_payments_count = failed_payments_count

      save_or_die! stat_entry
    else
      SubscriptionDailyCountChangeEvent.create! created_on: current_date,
                                                user: user,
                                                subscriptions_count: subscriptions_count,
                                                unsubscribers_count: unsubscribers_count,
                                                failed_payments_count: failed_payments_count
    end
  end

  private

  def current_month
    Time.zone.now.beginning_of_month..Time.zone.now
  end

  def current_date
    Time.zone.now.to_date
  end
end
