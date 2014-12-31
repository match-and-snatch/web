class CreateUserOffers < ActiveRecord::Migration
  def change
    create_table :user_offers do |t|
      t.references :user
      t.references :offer
    end
  end
end
