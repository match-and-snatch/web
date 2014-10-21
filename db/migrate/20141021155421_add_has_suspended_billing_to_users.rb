class AddHasSuspendedBillingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_suspended_billing, :boolean, null: false, default: false
  end
end
