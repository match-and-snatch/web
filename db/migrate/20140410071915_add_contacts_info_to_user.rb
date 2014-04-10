class AddContactsInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :contacts_info, :text
  end
end
