class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :action
      t.string :message
      t.text :data
      t.references :user
      t.timestamps
    end
  end
end
