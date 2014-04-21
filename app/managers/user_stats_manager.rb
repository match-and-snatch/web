class UserStatsManager < BaseManager
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def log_subscriptions_count
    stat_entry = SubscriptionDailyCountChangeEvent.where(created_on: current_date, user_id: user.id).first

    if stat_entry
      stat_entry.update_attribute(:subscriptions_count, user.source_subscriptions.count)
    else
      SubscriptionDailyCountChangeEvent.create! created_on:          current_date,
                                                user:                user,
                                                subscriptions_count: user.source_subscriptions.count
    end
  end

  private

  def current_date
    Time.zone.now.to_date
  end
end