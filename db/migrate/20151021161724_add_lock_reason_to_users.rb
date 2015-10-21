class AddLockReasonToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lock_reason, :string
  end
end
