class AddTimestampsToTopProfiles < ActiveRecord::Migration
  def change
    change_table :top_profiles do |t|
      t.timestamps
    end
  end
end
