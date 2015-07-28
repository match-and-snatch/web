class DenormalizeCustomUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_custom_welcome_message, :boolean, default: false, null: false
    add_column :users, :has_custom_profile_page_css, :boolean, default: false, null: false
  end
end
