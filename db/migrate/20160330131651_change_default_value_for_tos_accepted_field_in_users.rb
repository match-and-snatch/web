class ChangeDefaultValueForTosAcceptedFieldInUsers < ActiveRecord::Migration
  def change
    change_column :users, :tos_accepted, :boolean, default: true
  end
end
