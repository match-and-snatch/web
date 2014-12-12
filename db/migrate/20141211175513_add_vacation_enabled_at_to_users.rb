class AddVacationEnabledAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :vacation_enabled_at, :datetime
    remove_column :users, :billing_suspended
  end
end
