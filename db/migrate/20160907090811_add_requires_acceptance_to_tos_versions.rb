class AddRequiresAcceptanceToTosVersions < ActiveRecord::Migration
  def change
    add_column :tos_versions, :requires_acceptance, :boolean, default: true, null: false
  end
end
