class FillCostFieldInSubscriptions < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL.squish
          UPDATE subscriptions
          SET cost = users.cost, fees = users.subscription_fees, total_cost = users.subscription_cost
          FROM users
          WHERE subscriptions.target_user_id = users.id
        SQL
      end
    end
  end
end
