class AddCustomHeadJsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :custom_head_js, :text
  end
end
