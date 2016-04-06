class AddEmailUpdatedAtFieldToUsers < ActiveRecord::Migration
  def change
    add_column :users, :old_email, :string
    add_column :users, :email_updated_at, :datetime
  end
end
