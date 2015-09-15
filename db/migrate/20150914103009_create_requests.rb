class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :new_cost
      t.integer :old_cost
      t.boolean :approved, default: false, null: false
      t.boolean :rejected, default: false, null: false
      t.boolean :performed, default: false, null: false
      t.boolean :update_existing_subscriptions, default: false, null: false
      t.references :user, index: true, foreign_key: true
      t.string :type
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :performed_at
      t.timestamps null: false
    end
  end
end
