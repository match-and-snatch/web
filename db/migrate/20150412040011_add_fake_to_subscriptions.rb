class AddFakeToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :fake, :boolean, default: false, null: false
  end
end
