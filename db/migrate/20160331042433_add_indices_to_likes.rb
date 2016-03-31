class AddIndicesToLikes < ActiveRecord::Migration
  def change
    add_index :likes, :comment_id
    add_index :likes, :post_id
  end
end
