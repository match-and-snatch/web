class AddPaypalFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :prefers_paypal, :boolean, default: false, null: false
    add_column :users, :paypal_email, :string
  end
end
