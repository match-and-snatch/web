class CreateTopProfiles < ActiveRecord::Migration
  def change
    create_table :top_profiles do |t|
      t.references :user
      t.integer :position, default: 0, null: false
    end
  end
end
