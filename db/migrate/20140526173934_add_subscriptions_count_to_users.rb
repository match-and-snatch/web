class AddSubscriptionsCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :subscribers_count, :integer, default: 0, null: false

    User.reset_column_information

    User.find_each do |user|
      user.subscribers_count = user.source_subscriptions.count
      user.save!
    end
  end
end
