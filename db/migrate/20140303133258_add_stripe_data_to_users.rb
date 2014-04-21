class AddStripeDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_user_id, :string
    add_column :users, :stripe_card_id, :string
    add_column :users, :last_four_cc_numbers, :string
  end
end
