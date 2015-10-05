class AddRecentSubscriptionsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :recent_subscriptions_count, :integer, default: 0, null: false
    add_column :users, :recent_subscription_at, :datetime
  end
end
