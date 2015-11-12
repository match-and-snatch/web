class RemoveProfileTypesTextFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :profile_types_text, :text
  end
end
