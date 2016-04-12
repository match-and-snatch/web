class PopulatePostsCounterForUsers < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE users
          SET posts_count = pst.cnt
          FROM (SELECT posts.user_id AS usr_id, COUNT(posts.id) AS cnt
                FROM posts GROUP BY posts.user_id HAVING COUNT(posts.id) > 0) AS pst
          WHERE users.id = pst.usr_id
        SQL
      end
    end
  end
end
