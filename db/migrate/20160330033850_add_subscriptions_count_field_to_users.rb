class AddSubscriptionsCountFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscriptions_count, :integer, default: 0, null: false
  end
end
