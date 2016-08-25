class AddIndexToUsersOnBillingFailedField < ActiveRecord::Migration
  def change
    add_index :users, :billing_failed
  end
end
