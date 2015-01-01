class AddCallsEnabledToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :calls_enabled, :boolean
  end
end
