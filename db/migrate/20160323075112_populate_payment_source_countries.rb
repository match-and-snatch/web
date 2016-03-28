class PopulatePaymentSourceCountries < ActiveRecord::Migration
  COUNTRIES = ['US', 'CA', 'AR', 'AU', 'GB', 'KR', 'MX', 'RU', 'DE', 'DK', 'LV', 'SE', 'CZ', 'IE', 'SK', 'ES', 'BR', 'FI', 'IL', 'JP', 'NL', 'NO', 'BG', 'JO', 'ME', 'IT', 'EE', 'LB', 'NZ', 'CL', 'SG', 'GR', 'KZ', 'DO', 'FR', 'EC', 'AE', 'CH', 'PE', 'TR', 'KW', 'AD', 'BZ', 'AT', 'CR', 'UA', 'RO', 'IN', 'PR', 'BE', 'PT', 'PL', 'GH', 'PA', 'KY', 'ZA', 'NG', 'HK', 'IS', 'SI', 'SA', 'VG', 'MT', 'BM', 'CW', 'CN', 'QA', 'CO', 'KE', 'BY', 'UZ', 'PH', 'PY', 'JM', 'GT', 'ID', 'TH', 'MY', 'BS', 'RS', 'HN', 'TT', 'CI', 'ZW', 'TW', 'VI', 'SV', 'EG', 'LT', 'BB', 'LU', 'HU', 'AO', 'BH', 'HR', 'OM', 'UY', 'KN', 'AG', 'MO', 'LK', 'TN', 'DM', 'GY', 'GU', 'FJ', 'PK', 'SN', 'MA', 'AW', 'BA', 'BD', 'AZ', 'MU', 'GI', 'MZ', 'CY', 'CD', 'BW', 'TC', 'NE', 'PG', 'ML', 'LR', 'CM', 'HT', 'ZM', 'LC', 'VN', 'BF', 'TG', 'VC', 'TZ', 'BN', 'NI', 'IQ', 'DZ', 'MV', 'MK', 'BO', 'GM'].freeze

  def up
    total = Payment.count
    processed = 0

    COUNTRIES.each do |code|
      updated_count = Payment.where("stripe_charge_data LIKE '%country: #{code}%'").update_all(source_country: code)
      processed += updated_count
      puts "Populating payment sources for <#{code}>: #{updated_count}"
    end

    puts "Total Payments: #{total}"
    puts "With source country set: #{processed}"
    puts "Missing source: #{total - processed}"
  end

  def down
    Payment.update_all(stripe_charge_data: nil)
  end
end
