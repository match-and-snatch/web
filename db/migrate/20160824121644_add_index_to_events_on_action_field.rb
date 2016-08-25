class AddIndexToEventsOnActionField < ActiveRecord::Migration
  def change
    add_index :events, :action
    add_index :events, :created_at
  end
end
