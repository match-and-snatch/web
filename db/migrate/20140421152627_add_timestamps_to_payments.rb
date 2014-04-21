class AddTimestampsToPayments < ActiveRecord::Migration
  def change
    add_column(:payments, :created_at, :datetime)
    add_column(:payments, :updated_at, :datetime)
  end
end
