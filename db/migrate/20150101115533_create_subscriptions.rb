class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :offer
      t.string :query, limit: 1024
      t.timestamps
    end

    create_table :subscriptions_tags do |t|
      t.references :subscription
      t.references :tag
    end
  end
end
