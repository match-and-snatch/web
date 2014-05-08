class AddTimestampsToPaymentFailures < ActiveRecord::Migration
  def change
    change_table :payment_failures do |t|
      t.timestamps
    end
  end
end
