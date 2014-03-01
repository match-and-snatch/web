class AddSubscriptionCostToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscription_cost, :float
  end
end
