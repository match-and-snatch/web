class AddHiddenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hidden, :boolean, default: false, null: false
  end
end
