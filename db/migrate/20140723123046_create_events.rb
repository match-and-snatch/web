class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :type
      t.references :target, polymorphic: true
      t.text :data
      t.timestamps
    end
  end
end
