class DeleteOldDataFieldFromEvents < ActiveRecord::Migration
  def change
    remove_column :events, :old_data, :text
  end
end
