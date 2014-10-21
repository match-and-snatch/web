class AddHasSuspendedBillingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_suspended, :boolean, null: false, default: false
  end
end
