class AddOrderingToBenefits < ActiveRecord::Migration
  def change
    add_column :benefits, :ordering, :integer, default: 0, null: false
  end
end
