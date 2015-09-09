class AddHiddenFlagToFeedEvents < ActiveRecord::Migration
  def change
    add_column :feed_events, :hidden, :boolean, default: :false, null: false
  end
end
