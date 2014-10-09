class ChangeItunesEnabledDownloadsEnabledDefaultValue < ActiveRecord::Migration
  def change
    change_column :users, :downloads_enabled, :boolean, default: true
    change_column :users, :itunes_enabled, :boolean, default: true
  end
end
