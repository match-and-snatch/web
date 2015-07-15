class AddCoverPictureDimentionsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cover_picture_width, :integer
    add_column :users, :cover_picture_height, :integer
    add_column :users, :cover_picture_position_perc, :float
  end
end
