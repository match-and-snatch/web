class PopulateLastTimeLockedAt < ActiveRecord::Migration
  def up
    User.where('last_time_locked_at IS NULL').update_all(last_time_locked_at: 3.years.ago)
  end

  def down
    User.where('last_time_locked_at < ?', 2.years.ago).update_all(last_time_locked_at: nil)
  end
end
