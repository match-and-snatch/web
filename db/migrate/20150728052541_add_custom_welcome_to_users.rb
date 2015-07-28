class AddCustomWelcomeToUsers < ActiveRecord::Migration
  def change
    create_table :profile_pages do |t|
      t.references :user
      t.text :welcome_box
      t.text :css
    end
  end
end
