class PopulateStripeChargeIdFieldToPayments < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        Payment.update_all("stripe_charge_id = substring(stripe_charge_data from 'ch_[a-zA-Z0-9]+')")
      end

      direction.down do
        Payment.update_all(stripe_charge_id: nil)
      end
    end
  end
end
