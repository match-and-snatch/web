class PopulateLastPostCreatedAt < ActiveRecord::Migration
  def up
    update("UPDATE users set last_post_created_at = (SELECT MAX(posts.created_at) FROM posts WHERE posts.user_id = users.id)")
  end

  def down
    update("UPDATE users set last_post_created_at = NULL")
  end
end
