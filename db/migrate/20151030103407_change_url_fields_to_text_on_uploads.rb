class ChangeUrlFieldsToTextOnUploads < ActiveRecord::Migration
  def change
    change_column :uploads, :preview_url, :text
    change_column :uploads, :url, :text
    change_column :uploads, :retina_preview_url, :text
  end
end
