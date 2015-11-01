class RemoveIndexes < ActiveRecord::Migration
  def change
    remove_index(:users, :auth_token)
    remove_index(:users, :api_token)
    remove_index(:users, :slug)
  end
end
