class FixContributionDates < ActiveRecord::Migration
  def change
    update 'UPDATE contributions SET created_at = NOW() WHERE created_at IS NULL'
    update 'UPDATE contributions SET updated_at = NOW() WHERE updated_at IS NULL'
  end
end
