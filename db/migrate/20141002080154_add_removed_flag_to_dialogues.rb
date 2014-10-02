class AddRemovedFlagToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :removed, :boolean, default: false
    add_column :dialogues, :removed_at, :datetime
  end
end
