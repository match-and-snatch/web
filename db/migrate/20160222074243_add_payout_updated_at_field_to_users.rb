class AddPayoutUpdatedAtFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :payout_updated_at, :datetime
  end
end
