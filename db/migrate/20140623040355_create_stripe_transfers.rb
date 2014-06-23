class CreateStripeTransfers < ActiveRecord::Migration
  def change
    create_table :stripe_transfers do |t|
      t.references :user
      t.text :stripe_response
      t.integer :amount
      t.string :description
      t.timestamps
    end
  end
end
