class AddTargetUserIdIndexToSubscriptions < ActiveRecord::Migration
  def change
    add_index :subscriptions, :target_user_id
  end
end
