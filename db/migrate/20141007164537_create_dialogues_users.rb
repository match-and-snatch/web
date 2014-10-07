class CreateDialoguesUsers < ActiveRecord::Migration
  def change
    create_table :dialogues_users do |t|
      t.references :dialogue
      t.references :user
      t.boolean :removed, default: false, null: false
    end
  end
end
