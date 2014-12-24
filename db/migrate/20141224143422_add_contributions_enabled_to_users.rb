class AddContributionsEnabledToUsers < ActiveRecord::Migration
  def change
    add_column :users, :contributions_enabled, :boolean, default: true, null: false
  end
end
