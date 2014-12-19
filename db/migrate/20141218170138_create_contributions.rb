class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.integer :amount
      t.boolean :recurring, null: false, default: false
      t.references :user
      t.references :target_user
      t.references :parent
    end
  end
end
