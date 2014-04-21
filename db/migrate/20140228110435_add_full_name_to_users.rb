class AddFullNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :full_name, :string, limit: 512
  end
end
