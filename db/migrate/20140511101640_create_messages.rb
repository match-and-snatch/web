class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :user
      t.references :target_user
      t.text :message
      t.timestamp
    end

    create_table :dialogues do |t|
      t.references :user
      t.references :target_user
      t.references :recent_message
      t.timestamp
    end
  end
end
