class CreateFeedEvents < ActiveRecord::Migration
  def change
    create_table :feed_events do |t|
      t.string :type
      t.references :target, polymorphic: true
      t.references :target_user
      t.references :subscription_target_user
      t.text :data
      t.timestamps
    end
  end
end
