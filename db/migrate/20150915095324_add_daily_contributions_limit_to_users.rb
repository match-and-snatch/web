class AddDailyContributionsLimitToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_contributions_limit, :integer, default: 10000, null: false
  end
end
