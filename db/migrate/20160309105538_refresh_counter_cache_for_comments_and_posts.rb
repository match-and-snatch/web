class RefreshCounterCacheForCommentsAndPosts < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE comments
          SET likes_count = lks.cnt
          FROM (SELECT comments.id AS cmnt_id, COUNT(likes.id) AS cnt
                FROM comments
                INNER JOIN likes ON likes.comment_id = comments.id GROUP BY comments.id HAVING comments.likes_count != COUNT(likes.id)) AS lks
          WHERE comments.id = lks.cmnt_id
        SQL

        update <<-SQL.squish
          UPDATE posts
          SET likes_count = lks.cnt
          FROM (SELECT posts.id AS pst_id, COUNT(likes.id) AS cnt
                FROM posts
                INNER JOIN likes ON likes.post_id = posts.id GROUP BY posts.id HAVING posts.likes_count != COUNT(likes.id)) AS lks
          WHERE posts.id = lks.pst_id
        SQL

        update <<-SQL.squish
          UPDATE posts
          SET comments_count = cmnts.cnt
          FROM (SELECT posts.id AS pst_id, COUNT(comments.id) AS cnt
                FROM posts
                INNER JOIN comments ON comments.post_id = posts.id GROUP BY posts.id HAVING posts.comments_count != COUNT(comments.id)) AS cmnts
          WHERE posts.id = cmnts.pst_id
        SQL
      end
    end
  end
end
