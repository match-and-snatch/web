class AddSourceCountryToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :source_country, :string
  end
end
