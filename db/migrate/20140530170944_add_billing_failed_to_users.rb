class AddBillingFailedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_failed, :boolean, default: false, null: false
  end
end
