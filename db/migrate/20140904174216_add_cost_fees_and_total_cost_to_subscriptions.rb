class AddCostFeesAndTotalCostToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :current_cost, :float
    add_column :subscriptions, :current_fees, :float
    add_column :subscriptions, :total_cost, :float

    reversible do |direction|
      direction.up do
        Subscription.find_each do |subscription|
          target = subscription.target

          next if target.nil?

          subscription.current_cost = target.cost
          subscription.current_fees = target.subscription_fees
          subscription.total_cost = target.subscription_cost
          subscription.save(validate: false)
        end
      end
    end
  end
end
