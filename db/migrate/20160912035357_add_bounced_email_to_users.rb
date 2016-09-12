class AddBouncedEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_bounced_at, :datetime
  end
end
