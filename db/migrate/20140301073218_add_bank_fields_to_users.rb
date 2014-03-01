class AddBankFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :holder_name, :string
    add_column :users, :routing_number, :string
    add_column :users, :account_number, :string
  end
end
