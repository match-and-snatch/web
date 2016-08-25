class DowncaseEmailsForUsers < ActiveRecord::Migration
  def change
    update('UPDATE users SET email = LOWER(email)')
  end
end
