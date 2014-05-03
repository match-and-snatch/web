class AddActivatedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :activated, :boolean, default: false, null: false
  end
end
