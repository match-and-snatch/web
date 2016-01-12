class AddAdultSubscriptionsLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :adult_subscriptions_limit, :integer, default: 6, null: false
  end
end
