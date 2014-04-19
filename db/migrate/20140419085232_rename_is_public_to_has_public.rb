class RenameIsPublicToHasPublic < ActiveRecord::Migration
  def change
    rename_column :users, :is_public_profile, :has_public_profile
  end
end
