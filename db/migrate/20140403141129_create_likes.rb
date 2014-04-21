class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.references :user
      t.references :likable, polymorphic: true
      t.references :post
      t.references :target_user
      t.timestamps
    end
  end
end
