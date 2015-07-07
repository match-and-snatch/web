class AddStripeCardFingerprintToUsers < ActiveRecord::Migration
  def change
    add_column :users, :stripe_card_fingerprint, :string
  end
end
