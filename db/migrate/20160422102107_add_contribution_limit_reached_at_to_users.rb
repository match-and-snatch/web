class AddContributionLimitReachedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contribution_limit_reached_at, :datetime
  end
end
