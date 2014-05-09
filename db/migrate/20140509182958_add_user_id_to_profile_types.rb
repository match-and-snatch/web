class AddUserIdToProfileTypes < ActiveRecord::Migration
  def change
    add_column :profile_types, :user_id, :integer
  end
end
