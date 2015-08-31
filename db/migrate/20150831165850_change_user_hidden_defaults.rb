class ChangeUserHiddenDefaults < ActiveRecord::Migration
  def change
    change_column :users, :hidden, :boolean, default: true, null: false
  end
end
