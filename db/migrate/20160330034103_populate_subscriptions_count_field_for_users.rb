class PopulateSubscriptionsCountFieldForUsers < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE users
          SET subscriptions_count = sbscr.cnt
          FROM (SELECT subscriptions.user_id AS usr_id, COUNT(subscriptions.id) AS cnt
                FROM subscriptions GROUP BY subscriptions.user_id HAVING COUNT(subscriptions.id) > 0) AS sbscr
          WHERE users.id = sbscr.usr_id
        SQL
      end
    end
  end
end
