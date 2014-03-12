class AddOriginalProfilePictureUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :original_profile_picture_url, :text
  end
end
