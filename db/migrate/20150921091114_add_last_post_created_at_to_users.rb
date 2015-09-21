class AddLastPostCreatedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_post_created_at, :datetime
  end
end
