class PopulateGrossSalesStatistic < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL.squish
          UPDATE users
          SET gross_sales = sq.total_amount
          FROM (SELECT target_user_id, SUM(payments.amount) AS total_amount FROM payments GROUP BY payments.target_user_id) AS sq
          WHERE sq.target_user_id = users.id
        SQL

        execute <<-SQL.squish
          UPDATE users
          SET gross_contributions = sq.total_amount
          FROM (SELECT target_user_id, SUM(contributions.amount) AS total_amount FROM contributions GROUP BY contributions.target_user_id) AS sq
          WHERE sq.target_user_id = users.id
        SQL
      end
    end
  end
end
