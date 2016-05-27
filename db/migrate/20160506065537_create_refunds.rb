class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.string :stripe_refund_id, null: false
      t.integer :amount, null: false, default: 0
      t.integer :payment_amount
      t.string :balance_transaction
      t.string :charge, null: false
      t.string :currency, null: false, default: 'usd'
      t.text :metadata
      t.string :reason
      t.string :receipt_number
      t.string :status, null: false
      t.datetime :payment_date
      t.datetime :refunded_at, null: false
      t.references :payment
      t.references :user

      t.timestamps null: false
    end
  end
end
