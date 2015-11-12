class RestoreBtreeUserIndexes < ActiveRecord::Migration
  def change
    add_index(:users, :auth_token)
    add_index(:users, :api_token)
    add_index(:users, :slug)
  end
end
