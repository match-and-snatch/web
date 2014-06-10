class AddUnreadToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :unread, :boolean, default: true, null: false
  end
end
