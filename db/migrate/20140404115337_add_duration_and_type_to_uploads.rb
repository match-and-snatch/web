class AddDurationAndTypeToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :duration, :float
    add_column :uploads, :type, :string
    add_column :uploads, :mime_type, :string
  end
end
