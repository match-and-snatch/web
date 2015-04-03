module Events
  class RemoveDuplicatesJob
    def self.perform
      ActiveRecord::Base.connection.execute <<-SQL
        DELETE FROM events
        WHERE id IN (SELECT id
                     FROM (SELECT id, row_number()
                           OVER (PARTITION BY action, user_id, created_at::timestamp(0), updated_at::timestamp(0), message, data
                           ORDER BY id) AS rnum
                           FROM events) AS evnts
                     WHERE evnts.rnum > 1)
      SQL
    end
  end
end
