class AddStripeCardTypeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :card_type, :string
  end
end
