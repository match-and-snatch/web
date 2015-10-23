class AddAuthTokenIndex < ActiveRecord::Migration
  def change
    add_index(:users, :auth_token, using: 'hash')
  end
end
