class AddBenefitsVisibleFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :benefits_visible, :boolean, default: true, null: false
  end
end
