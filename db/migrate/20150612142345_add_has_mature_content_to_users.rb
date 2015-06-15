class AddHasMatureContentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_mature_content, :boolean, default: false, null: false
  end
end
