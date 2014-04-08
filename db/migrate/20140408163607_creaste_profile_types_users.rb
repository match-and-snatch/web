class CreasteProfileTypesUsers < ActiveRecord::Migration
  def change
    create_table :profile_types_users do |t|
      t.references :user
      t.references :profile_type
      t.integer :ordering, default: 0, null: false
    end
  end
end
