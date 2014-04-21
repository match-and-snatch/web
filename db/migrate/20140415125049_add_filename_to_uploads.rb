class AddFilenameToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :filename, :text
  end
end
