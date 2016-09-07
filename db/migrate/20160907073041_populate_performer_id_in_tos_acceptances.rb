class PopulatePerformerIdInTosAcceptances < ActiveRecord::Migration
  def change
    update("UPDATE tos_acceptances SET performer_id = tos_acceptances.user_id")
  end
end
