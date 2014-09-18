class CreateEvents < ActiveRecord::Migration
  def up
    drop_table :events if ActiveRecord::Base.connection.table_exists? :events
    create_table :events do |t|
      t.string :action
      t.string :message
      t.text :data
      t.references :user
      t.timestamps
    end
  end
  def down
    drop_table :events
  end
end
