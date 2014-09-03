class CreateTrackingEvents < ActiveRecord::Migration
  def change
    create_table :tracking_events do |t|
      t.string :message
      t.string :type
      t.text :data
      t.references :user
      t.timestamps
    end
  end
end
