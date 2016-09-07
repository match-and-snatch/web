class AddActiveFlagToTosVersions < ActiveRecord::Migration
  def up
    add_column :tos_versions, :active, :boolean, default: false, null: false
    version = TosVersion.published.order(published_at: :desc).first
    version.update!(active: true) if version
  end

  def down
    remove_column :tos_versions, :active
  end
end
