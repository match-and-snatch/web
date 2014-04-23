class AddSmallProfilePictureUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :small_profile_picture_url, :text
  end
end
