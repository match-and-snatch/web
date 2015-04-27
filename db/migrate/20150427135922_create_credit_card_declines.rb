class CreateCreditCardDeclines < ActiveRecord::Migration
  def change
    create_table :credit_card_declines do |t|
      t.belongs_to :user
      t.string :stripe_fingerprint
      t.timestamps
    end
  end
end
