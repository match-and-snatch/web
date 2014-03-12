class AddProfilePictureUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_picture_url, :text
  end
end
