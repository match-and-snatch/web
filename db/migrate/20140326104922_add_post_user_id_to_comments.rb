class AddPostUserIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :post_user_id, :integer
  end
end
