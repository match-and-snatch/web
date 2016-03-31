class AddIndicesAndRepliesCounterCacheToComments < ActiveRecord::Migration
  def change
    add_column :comments, :replies_count, :integer, default: 0, null: false

    add_index :comments, :parent_id
    add_index :comments, :post_id

    reversible do |direction|
      direction.up do
        update <<-SQL.squish
          UPDATE comments
          SET replies_count = rpls.cnt
          FROM (SELECT comments.parent_id AS cmnt_id, COUNT(comments.id) AS cnt
                FROM comments
                WHERE comments.parent_id IS NOT NULL
                GROUP BY comments.parent_id) AS rpls
          WHERE comments.id = rpls.cmnt_id
        SQL
      end
    end
  end
end
