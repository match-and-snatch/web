class AddCoverPictureUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_picture_url, :text
    add_column :users, :original_cover_picture_url, :text
  end
end
