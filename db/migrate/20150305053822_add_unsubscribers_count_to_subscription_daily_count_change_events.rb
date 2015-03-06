class AddUnsubscribersCountToSubscriptionDailyCountChangeEvents < ActiveRecord::Migration
  def change
    add_column :subscription_daily_count_change_events, :unsubscribers_count, :integer, default: 0
    add_column :subscription_daily_count_change_events, :failed_payments_count, :integer, default: 0
  end
end
