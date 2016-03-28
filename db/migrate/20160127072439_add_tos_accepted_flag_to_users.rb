class AddTosAcceptedFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tos_accepted, :boolean, default: false, null: false
  end
end
