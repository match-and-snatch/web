class MoveAllRequestsToSingleTable < ActiveRecord::Migration
  def up
    execute <<-SQL.squish
      INSERT INTO requests (new_cost, old_cost, approved, rejected, performed, update_existing_subscriptions, user_id, type, approved_at, rejected_at, performed_at, created_at, updated_at)
      SELECT new_cost, old_cost, approved, rejected, performed, update_existing_subscriptions, user_id, cast('CostChangeRequest' AS varchar(255)) AS type, approved_at, rejected_at, performed_at, created_at, updated_at
      FROM cost_change_requests
    SQL

    execute <<-SQL.squish
      INSERT INTO requests (approved, rejected, performed, user_id, type, approved_at, rejected_at, performed_at, created_at, updated_at)
      SELECT approved, rejected, performed, user_id, cast('DeleteProfilePageRequest' AS varchar(255)) AS type, approved_at, rejected_at, performed_at, created_at, updated_at
      FROM delete_profile_page_requests
    SQL

    drop_table :cost_change_requests
    drop_table :delete_profile_page_requests
  end

  def down
    create_table :cost_change_requests do |t|
      t.integer :new_cost
      t.integer :old_cost
      t.boolean :approved, default: false, null: false
      t.boolean :rejected, default: false, null: false
      t.boolean :performed, default: false, null: false
      t.boolean :update_existing_subscriptions, default: false, null: false
      t.references :user
      t.datetime :approved_at
      t.datetime :rejected_at
      t.datetime :performed_at
      t.timestamps
    end

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

    execute <<-SQL.squish
      INSERT INTO cost_change_requests (new_cost, old_cost, approved, rejected, performed, update_existing_subscriptions, user_id, approved_at, rejected_at, performed_at, created_at, updated_at)
      SELECT new_cost, old_cost, approved, rejected, performed, update_existing_subscriptions, user_id, approved_at, rejected_at, performed_at, created_at, updated_at
      FROM requests
      WHERE type = 'CostChangeRequest'
    SQL

    execute <<-SQL.squish
      INSERT INTO delete_profile_page_requests (approved, rejected, performed, user_id, approved_at, rejected_at, performed_at, created_at, updated_at)
      SELECT approved, rejected, performed, user_id, approved_at, rejected_at, performed_at, created_at, updated_at
      FROM requests
      WHERE type = 'DeleteProfilePageRequest'
    SQL
  end
end
