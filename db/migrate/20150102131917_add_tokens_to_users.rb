class AddTokensToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :password_salt
      t.string :password_hash
      t.string :password_reset_token
      t.string :auth_token
      t.string :registration_token
    end
  end
end
