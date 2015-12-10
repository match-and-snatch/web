class DecreaseDefaultDailyContributionsLimit < ActiveRecord::Migration
  def up
    change_column :users, :daily_contributions_limit, :integer, default: 3000, null: false
    User.where(daily_contributions_limit: 10000).update_all(daily_contributions_limit: 3000)
  end

  def down
    change_column :users, :daily_contributions_limit, :integer, default: 10000, null: false
    User.where(daily_contributions_limit: 3000).update_all(daily_contributions_limit: 10000)
  end
end
