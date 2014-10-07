class PopupateUsersOnDialogues < ActiveRecord::Migration
  def up
    Dialogue.all.find_each do |dialogue|
      dialogue.dialogues_users.create!(user_id: dialogue.user_id)
      dialogue.dialogues_users.create!(user_id: dialogue.target_user_id)
    end
  end

  def down
    DialoguesUser.delete_all
  end
end
