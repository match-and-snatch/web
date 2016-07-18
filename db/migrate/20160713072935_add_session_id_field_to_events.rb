class AddSessionIdFieldToEvents < ActiveRecord::Migration
  def change
    add_column :events, :session_id, :string
  end
end
