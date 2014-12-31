class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.string :title, limit: 1024
      t.references :user
      t.timestamps
    end
  end
end
