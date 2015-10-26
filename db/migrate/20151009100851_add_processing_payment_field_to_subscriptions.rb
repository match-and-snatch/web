class AddProcessingPaymentFieldToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :processing_payment, :boolean, default: false, null: false
    add_column :subscriptions, :processing_started_at, :datetime
  end
end
