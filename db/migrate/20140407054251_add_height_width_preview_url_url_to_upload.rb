class AddHeightWidthPreviewUrlUrlToUpload < ActiveRecord::Migration
  def change
  	add_column :uploads, :width, :integer
    add_column :uploads, :height, :integer
    add_column :uploads, :preview_url, :string
    add_column :uploads, :url, :string
  end
end
