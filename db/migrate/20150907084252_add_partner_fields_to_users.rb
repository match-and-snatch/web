class AddPartnerFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :partner_id, :integer
    add_column :users, :partner_fees, :integer
  end
end
