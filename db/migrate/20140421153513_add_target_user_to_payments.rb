class AddTargetUserToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :target_user_id, :integer
  end
end
