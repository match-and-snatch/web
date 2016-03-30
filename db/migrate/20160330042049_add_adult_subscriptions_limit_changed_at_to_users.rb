class AddAdultSubscriptionsLimitChangedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :adult_subscriptions_limit_changed_at, :datetime
  end
end
