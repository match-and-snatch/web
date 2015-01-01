class AddHitsCountToOffers < ActiveRecord::Migration
  def change
    add_column :offers, :hits_count, :integer, default: 0, null: false
  end
end
