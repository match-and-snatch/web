class PopulateAddressDataFieldInPayments < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        puts "started at #{Time.zone.now.to_s(:long)}"
        i = 0
        total = Payment.count
        Payment.find_in_batches do |group|
          group.each do |payment|
            store = payment.stripe_charge_data['source'] || payment.stripe_charge_data['card'] || {}

            payment.update_columns billing_address_city: store['address_city'],
                                   billing_address_country: store['address_country'],
                                   billing_address_line_1: store['address_line1'],
                                   billing_address_line_2: store['address_line2'],
                                   billing_address_state: store['address_state'],
                                   billing_address_zip: store['address_zip']
            i += 1
          end
          puts "processed #{i} from #{total}"
        end
        puts "finished at #{Time.zone.now.to_s(:long)}"
      end

      direction.down do
        Payment.update_all billing_address_city: nil,
                           billing_address_country: nil,
                           billing_address_line_1: nil,
                           billing_address_line_2: nil,
                           billing_address_state: nil,
                           billing_address_zip: nil
      end
    end
  end
end
