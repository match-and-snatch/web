class RepopulateSubjectForSubscriptionEvents < ActiveRecord::Migration
  def change
    update <<-SQL.squish
      UPDATE events
      SET subject_type = 'Subscription', subject_id = substring(substring(events.data from 'subscription_id: [0-9]+') from '[0-9]+')::integer
      WHERE events.action = 'subscription_canceled'
    SQL
  end
end
