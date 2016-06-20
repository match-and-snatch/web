class AddPinnedFlagToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :pinned, :boolean, default: false, null: false
  end
end
