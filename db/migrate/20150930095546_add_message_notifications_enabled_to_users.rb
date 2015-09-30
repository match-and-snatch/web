class AddMessageNotificationsEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :message_notifications_enabled, :boolean, default: true, null: false
  end
end
