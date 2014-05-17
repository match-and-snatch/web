class AddNotificationsEnabledToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :notifications_enabled, :boolean, default: true, null: false
  end
end
