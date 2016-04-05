class AddIndicesToPayments < ActiveRecord::Migration
  def change
    add_index :payments, :target_user_id
    add_index :payments, :user_id
  end
end
