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
    count = user.source_subscriptions.not_removed.count
    user.subscribers_count = count
    save_or_die! user

    stat_entry = SubscriptionDailyCountChangeEvent.where(created_on: current_date, user_id: user.id).first

    if stat_entry
      stat_entry.subscriptions_count = count
      save_or_die! stat_entry
      stat_entry
    else
      SubscriptionDailyCountChangeEvent.create! created_on: current_date,
                                                user: user,
                                                subscriptions_count: count
    end
  end

  private

  def current_date
    Time.zone.now.to_date
  end
end
