class AddBillingAddressToUsers < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :billing_address_city
      t.string :billing_address_state
      t.string :billing_address_zip
      t.text :billing_address_line_1
      t.text :billing_address_line_2
    end
  end
end
