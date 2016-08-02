class CreateTosAcceptances < ActiveRecord::Migration
  def change
    create_table :tos_acceptances do |t|
      t.string :user_email
      t.string :user_full_name
      t.references :user
      t.references :tos_version

      t.timestamps null: false
    end
  end
end
