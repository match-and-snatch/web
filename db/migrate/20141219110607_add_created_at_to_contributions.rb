class AddCreatedAtToContributions < ActiveRecord::Migration
  def change
    change_table :contributions do |t|
      t.timestamps
    end
  end
end
