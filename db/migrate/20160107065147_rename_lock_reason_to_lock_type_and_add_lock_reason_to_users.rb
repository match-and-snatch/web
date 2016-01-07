class RenameLockReasonToLockTypeAndAddLockReasonToUsers < ActiveRecord::Migration
  def up
    rename_column :users, :lock_reason, :lock_type
    add_column :users, :lock_reason, :string

    User.where(lock_type: 'weekly_contribution_limit').update_all(lock_type: 'billing', lock_reason: 'contribution_limit')
  end

  def down
    User.where(lock_type: 'billing', lock_reason: 'contribution_limit').update_all(lock_type: 'weekly_contribution_limit')

    remove_column :users, :lock_reason
    rename_column :users, :lock_type, :lock_reason
  end
end
