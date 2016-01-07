class RenameReasonToTypeInAccountLockedEvents < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        execute <<-SQL.squish
          UPDATE events
          SET data = REPLACE (data, ':reason:', ':type:')
          WHERE action = 'account_locked'
        SQL
      end
    end
  end
end
