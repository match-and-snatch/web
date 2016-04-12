class CreateCommentIgnores < ActiveRecord::Migration
  def change
    create_table :comment_ignores do |t|
      t.references :user
      t.references :commenter

      t.timestamps null: false
    end
  end
end
