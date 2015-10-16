class AddReadFlagToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :read, :boolean, default: :false, null: false
    add_column :messages, :read_at, :datetime
  end
end
