class AddCommentIdToLikes < ActiveRecord::Migration
  def change
    change_table :likes do |t|
      t.references :comment
    end
  end
end
