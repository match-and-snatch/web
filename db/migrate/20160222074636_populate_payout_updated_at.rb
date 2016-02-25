class PopulatePayoutUpdatedAt < ActiveRecord::Migration
  def up
    update <<-SQL.squish
      UPDATE users
      SET payout_updated_at = evt.max_payout_updated_at
      FROM (SELECT MAX(events.created_at) AS max_payout_updated_at, events.user_id
            FROM events
            WHERE events.action = 'payout_information_changed'
            GROUP BY events.user_id) AS evt
      WHERE evt.user_id = users.id
    SQL
  end

  def down
    update <<-SQL
      UPDATE users set payout_updated_at = NULL
    SQL
  end
end
