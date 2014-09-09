class AddCostFeesAndTotalCostToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :cost, :float
    add_column :subscriptions, :fees, :float
    add_column :subscriptions, :total_cost, :float
  end
end
