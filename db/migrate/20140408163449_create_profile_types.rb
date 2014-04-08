class CreateProfileTypes < ActiveRecord::Migration
  def change
    create_table :profile_types do |t|
      t.string :title
      t.integer :ordering, default: 0, null: false
    end
  end
end
