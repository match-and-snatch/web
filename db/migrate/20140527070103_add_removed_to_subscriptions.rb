class AddRemovedToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :removed, :boolean, default: false, null: false
    add_column :subscriptions, :removed_at, :datetime
  end
end
