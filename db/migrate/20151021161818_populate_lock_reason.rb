class PopulateLockReason < ActiveRecord::Migration
  def up
    User.where(locked: true).update_all(lock_reason: 'billing')
  end

  def down
    User.where(locked: true).update_all(lock_reason: nil)
  end
end
