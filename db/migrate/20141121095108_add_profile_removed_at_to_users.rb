class AddProfileRemovedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_removed_at, :datetime
  end
end
