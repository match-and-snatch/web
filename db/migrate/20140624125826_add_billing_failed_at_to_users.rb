class AddBillingFailedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_failed_at, :datetime
  end
end
