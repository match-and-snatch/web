class AddChargeDateToSubscriptions < ActiveRecord::Migration
  def change
    add_column :subscriptions, :charge_date, :datetime
  end
end
