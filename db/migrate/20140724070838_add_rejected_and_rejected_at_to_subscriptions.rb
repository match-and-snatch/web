class AddRejectedAndRejectedAtToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :rejected, :boolean, default: false, null: false
    add_column :subscriptions, :rejected_at, :datetime
  end
end
