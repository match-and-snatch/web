class AddIndexToSubscriptionsOnCreatedAtField < ActiveRecord::Migration
  def change
    add_index :subscriptions, :created_at
    add_index :subscriptions, :rejected
    add_index :subscriptions, :removed
    add_index :subscriptions, :removed_at
  end
end
