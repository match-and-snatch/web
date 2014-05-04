class AddFilesizeToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :filesize, :integer
  end
end
