class AddIndexToPaymentsOnCreatedAtField < ActiveRecord::Migration
  def change
    add_index :payments, :created_at
  end
end
