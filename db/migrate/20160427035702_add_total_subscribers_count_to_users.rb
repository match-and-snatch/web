class AddTotalSubscribersCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :total_subscribers_count, :integer, default: 0, null: false
  end
end
