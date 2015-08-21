class AddSpecialOfferFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :has_special_offer, :boolean, default: false, null: false
  end
end
