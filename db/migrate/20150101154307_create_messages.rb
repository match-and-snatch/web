class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :parent
      t.references :offer
      t.references :user
      t.text :content
      t.datetime :read_at
      t.timestamps null: false
    end
  end
end
