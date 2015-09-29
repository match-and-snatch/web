class AddAcceptsLargeContributionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accepts_large_contributions, :boolean, default: false, null: false
  end
end
