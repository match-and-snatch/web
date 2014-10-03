class AddCostFeesAndTotalCostToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :cost, :integer
    add_column :subscriptions, :fees, :integer
    add_column :subscriptions, :total_cost, :integer
  end
end
