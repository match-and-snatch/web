class AddEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string, limit: 512
  end
end
