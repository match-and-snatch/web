class AddCostChangedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :cost_changed_at, :datetime
  end
end
