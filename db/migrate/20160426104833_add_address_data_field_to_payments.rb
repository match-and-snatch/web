class AddAddressDataFieldToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :billing_address_city, :string
    add_column :payments, :billing_address_country, :string
    add_column :payments, :billing_address_line_1, :string
    add_column :payments, :billing_address_line_2, :string
    add_column :payments, :billing_address_state, :string
    add_column :payments, :billing_address_zip, :string
  end
end
