class AddLastTimeLcokedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_time_locked_at, :datetime
  end
end
