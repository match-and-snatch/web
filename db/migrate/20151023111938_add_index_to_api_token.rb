class AddIndexToApiToken < ActiveRecord::Migration
  def change
    add_index(:users, :api_token, using: 'hash')
  end
end
