class AddCoverPicturePositionToUser < ActiveRecord::Migration
  def change
    add_column :users, :cover_picture_position, :integer, default: 0, null: false
  end
end
