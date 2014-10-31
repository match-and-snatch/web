class CreateCostChangeRequests < ActiveRecord::Migration
  def change
    create_table :cost_change_requests do |t|
      t.integer :new_cost
      t.boolean :approved, default: false, null: false
      t.boolean :rejected, default: false, null: false
      t.references :user
      t.datetime :approved_at
      t.datetime :rejected_at
      t.timestamps
    end
  end
end
