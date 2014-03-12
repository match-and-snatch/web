class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.references :uploadable, polymorphic: true
      t.text :transloadit_data
    end
  end
end
