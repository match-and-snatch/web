class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :user
      t.references :target, polymorphic: true
      t.references :target_user
      t.timestamps
    end
  end
end
