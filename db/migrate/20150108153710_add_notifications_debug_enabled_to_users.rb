class AddNotificationsDebugEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :notifications_debug_enabled, :boolean, default: true
  end
end
