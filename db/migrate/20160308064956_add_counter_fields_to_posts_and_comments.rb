class AddCounterFieldsToPostsAndComments < ActiveRecord::Migration
  def change
    add_column :posts, :comments_count, :integer, default: 0, null: false
    add_column :posts, :likes_count, :integer, default: 0, null: false
    add_column :comments, :likes_count, :integer, default: 0, null: false
  end
end
