class RemoveUserFieldsFromDialogues < ActiveRecord::Migration
  def up
    remove_column :dialogues, :target_user_id
    remove_column :dialogues, :user_id
  end

  def down
    change_table :dialogues do |t|
      t.references :user
      t.references :target_user
    end
  end
end
