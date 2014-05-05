class AddProfileConfigToUsers < ActiveRecord::Migration
  def change
    add_column :users, :rss_enabled, :boolean, default: false, null: false
    add_column :users, :downloads_enabled, :boolean, default: false, null: false
    add_column :users, :itunes_enabled, :boolean, default: false, null: false
  end
end
