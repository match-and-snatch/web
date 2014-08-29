class AddTimestampsToUploads < ActiveRecord::Migration
  def change
    change_table :uploads do |t|
      t.timestamps
    end
  end
end
