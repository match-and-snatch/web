class ConvertCostsFromDollarsToCents < ActiveRecord::Migration
  def up
    execute <<-SQL.squish
      UPDATE users
      SET cost = cost * 100, subscription_fees = subscription_fees * 100, subscription_cost = subscription_cost * 100
    SQL

    change_column :users, :subscription_cost, :integer
    change_column :users, :subscription_fees, :integer

    execute <<-SQL.squish
      UPDATE payments
      SET user_cost = user_cost * 100, user_subscription_fees = user_subscription_fees * 100, user_subscription_cost = user_subscription_cost * 100
    SQL

    change_column :payments, :user_cost, :integer
    change_column :payments, :user_subscription_cost, :integer
    change_column :payments, :user_subscription_fees, :integer

    rename_column :payments, :user_cost, :cost
    rename_column :payments, :user_subscription_cost, :subscription_cost
    rename_column :payments, :user_subscription_fees, :subscription_fees
  end

  def down
    change_column :users, :subscription_cost, :float
    change_column :users, :subscription_fees, :float

    execute <<-SQL.squish
      UPDATE users
      SET cost = cost / 100, subscription_fees = subscription_fees / 100, subscription_cost = subscription_cost / 100
    SQL

    change_column :payments, :user_cost, :float
    change_column :payments, :user_subscription_cost, :float
    change_column :payments, :user_subscription_fees, :float

    rename_column :payments, :cost, :user_cost
    rename_column :payments, :subscription_cost, :user_subscription_cost
    rename_column :payments, :subscription_fees, :user_subscription_fees

    execute <<-SQL.squish
      UPDATE payments
      SET user_cost = user_cost / 100, user_subscription_fees = user_subscription_fees / 100, user_subscription_cost = user_subscription_cost / 100
    SQL
  end
end
