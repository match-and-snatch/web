class CreateSubscriptionCountChangeEvent < ActiveRecord::Migration
  def change
    create_table :subscription_daily_count_change_events do |t|
      t.integer :subscriptions_count
      t.timestamps
      t.date :created_on
      t.references :user
    end
  end
end
