class AddRecentMessageAtToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :recent_message_at, :datetime
  end
end
