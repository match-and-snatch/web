class AddMentionsToComments < ActiveRecord::Migration
  def change
    add_column :comments, :mentions, :text
  end
end
