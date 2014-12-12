class AddRemovedFlagToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :removed, :boolean, default: false
    add_column :uploads, :removed_at, :datetime
  end
end
