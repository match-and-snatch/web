class AddProfileNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :profile_name, :string, limit: 512
  end
end
