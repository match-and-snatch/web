class AddOrderingToUploads < ActiveRecord::Migration
  def change
    add_column :uploads, :ordering, :integer, default: 0, null: false
  end
end
