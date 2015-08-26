class CreateDeleteProfilePageRequests < ActiveRecord::Migration
  def change
    create_table :delete_profile_page_requests do |t|
      t.boolean :approved, default: false, null: false
      t.boolean :rejected, default: false, null: false
      t.boolean :performed, default: false, null: false
      t.references :user
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :performed_at
      t.timestamps
    end
  end
end
