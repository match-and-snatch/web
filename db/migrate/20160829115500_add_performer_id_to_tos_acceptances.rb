class AddPerformerIdToTosAcceptances < ActiveRecord::Migration
  def change
    add_column :tos_acceptances, :performer_id, :integer
    add_column :tos_acceptances, :performed_by_admin, :boolean, default: false, null: false
  end
end
