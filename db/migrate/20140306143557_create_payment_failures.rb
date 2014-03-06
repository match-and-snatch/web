class CreatePaymentFailures < ActiveRecord::Migration
  def change
    create_table :payment_failures do |t|
      t.references :user
      t.references :target, polymorphic: true
      t.text :exception_data
      t.text :stripe_charge_data
      t.text :description
    end
  end
end
