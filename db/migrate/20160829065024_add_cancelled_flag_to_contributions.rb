class AddCancelledFlagToContributions < ActiveRecord::Migration
  def change
    add_column :contributions, :cancelled, :boolean, default: false, null: false
    add_column :contributions, :cancelled_at, :datetime
  end
end
