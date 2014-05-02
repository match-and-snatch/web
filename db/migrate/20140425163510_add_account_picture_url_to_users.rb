class AddAccountPictureUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :account_picture_url, :text
    add_column :users, :small_account_picture_url, :text
    add_column :users, :original_account_picture_url, :text
  end
end
