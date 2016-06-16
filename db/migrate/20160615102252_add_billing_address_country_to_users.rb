class AddBillingAddressCountryToUsers < ActiveRecord::Migration
  def change
    add_column :users, :billing_address_country, :string
  end
end
