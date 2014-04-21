class AddHasCompleteProfileToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_complete_profile, :boolean, default: false, null: false
  end
end
