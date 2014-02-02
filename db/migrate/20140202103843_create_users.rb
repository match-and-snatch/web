class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :slug
      t.string :email
      t.string :password_salt
      t.string :password_hash
      t.timestamps
    end
  end
end
