class AddProfileTypeTextToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_types_text, :text
  end
end
