class AddSpecialOfferToProfilePages < ActiveRecord::Migration
  def change
    add_column :profile_pages, :special_offer, :text
  end
end
