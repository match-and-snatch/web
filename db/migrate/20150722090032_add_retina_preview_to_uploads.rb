class AddRetinaPreviewToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :retina_preview_url, :string
  end
end
