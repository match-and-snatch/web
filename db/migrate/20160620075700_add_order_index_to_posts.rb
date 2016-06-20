class AddOrderIndexToPosts < ActiveRecord::Migration
  def change
    add_index :posts, [:pinned, :created_at]
  end
end
