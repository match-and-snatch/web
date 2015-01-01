class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :title, limit: 512
      t.references :user
      t.timestamps null: false
    end
  end
end
