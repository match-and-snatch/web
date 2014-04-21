class AddFeesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscription_fees, :float
    add_column :users, :cost, :integer
  end
end
