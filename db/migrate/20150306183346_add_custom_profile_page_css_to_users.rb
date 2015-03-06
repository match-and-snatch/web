class AddCustomProfilePageCssToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_profile_page_css, :text
  end
end
