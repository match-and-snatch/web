class AddZipCheckFailedToUsers < ActiveRecord::Migration
  def up
    add_column :users, :billing_zip_check_failed, :boolean
    update("UPDATE users SET billing_zip_check_failed = 'f'")
  end

  def down
    remove_column :users, :billing_zip_check_failed
  end
end
