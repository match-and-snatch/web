class AddS3PathsToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :s3_paths, :text
  end
end
