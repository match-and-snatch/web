class AddIsSalesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_sales, :boolean, default: false, null: false
  end
end
