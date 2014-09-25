class AddLastVisitedProfileIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_visited_profile_id, :integer
  end
end
