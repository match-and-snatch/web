class AddIndicesToUploads < ActiveRecord::Migration
  def change
    add_index :uploads, [:uploadable_id, :uploadable_type]
  end
end
