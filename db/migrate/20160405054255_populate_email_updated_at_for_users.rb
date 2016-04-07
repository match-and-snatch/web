class PopulateEmailUpdatedAtForUsers < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE users
          SET email_updated_at = evt.max_email_updated_at
          FROM (SELECT MAX(events.created_at) AS max_email_updated_at, events.user_id
            FROM events
            WHERE events.action = 'account_information_changed'
            GROUP BY events.user_id) AS evt
          WHERE evt.user_id = users.id
        SQL
      end

      direction.down do
        update <<-SQL.squish
          UPDATE users set email_updated_at = NULL
        SQL
      end
    end
  end
end
