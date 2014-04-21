class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :target, polymorphic: true
      t.references :user
      t.integer :amount
      t.text :stripe_charge_data
      t.text :description
    end
  end
end
