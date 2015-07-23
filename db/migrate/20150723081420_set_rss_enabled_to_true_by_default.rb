class SetRssEnabledToTrueByDefault < ActiveRecord::Migration
  def change
    change_column :users, :rss_enabled, :boolean, default: true, null: false
  end
end
