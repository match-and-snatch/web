class AddBasenameToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :basename, :text
  end
end
