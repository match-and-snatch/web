class AddHiddenToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :hidden, :boolean, default: false, null: false
  end
end
