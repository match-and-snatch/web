class AddDialogueIdToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :dialogue_id, :integer
  end
end
