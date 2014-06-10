class AddReadAtToDialogues < ActiveRecord::Migration
  def change
    add_column :dialogues, :read_at, :datetime
  end
end
