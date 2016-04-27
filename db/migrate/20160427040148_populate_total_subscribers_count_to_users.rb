class PopulateTotalSubscribersCountToUsers < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE users
          SET total_subscribers_count = sbscrptns.cnt
          FROM (SELECT subscriptions.target_user_id AS usr_id, COUNT(subscriptions.id) AS cnt
                FROM subscriptions GROUP BY subscriptions.target_user_id HAVING COUNT(subscriptions.id) > 0) AS sbscrptns
          WHERE users.id = sbscrptns.usr_id
        SQL
      end
    end
  end
end
