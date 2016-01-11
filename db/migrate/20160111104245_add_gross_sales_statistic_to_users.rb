class AddGrossSalesStatisticToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gross_sales, :integer, default: 0, null: false
    add_column :users, :gross_contributions, :integer, default: 0, null: false
  end
end
