class AddZipCheckFailedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_zip_check_failed, :boolean
  end
end
