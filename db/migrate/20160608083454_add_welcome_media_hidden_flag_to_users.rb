class AddWelcomeMediaHiddenFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :welcome_media_hidden, :boolean, default: false, null: false
  end
end
