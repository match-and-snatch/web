class SetNotificationFlagOnUsers < ActiveRecord::Migration
  def change
    User.update_all(notifications_debug_enabled: false)
  end
end
