class CreateTosVersions < ActiveRecord::Migration
  def change
    create_table :tos_versions do |t|
      t.text :tos, null: false
      t.datetime :published_at
      t.timestamps null: false
    end
  end
end
