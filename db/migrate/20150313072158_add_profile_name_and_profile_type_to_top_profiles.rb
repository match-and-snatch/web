class AddProfileNameAndProfileTypeToTopProfiles < ActiveRecord::Migration
  def change
    add_column :top_profiles, :profile_name, :string
    add_column :top_profiles, :profile_types_text, :text
  end
end
