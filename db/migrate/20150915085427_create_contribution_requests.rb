class CreateContributionRequests < ActiveRecord::Migration
  def change
    add_column :requests, :amount, :integer
    add_column :requests, :recurring, :boolean, default: false, null: false
    add_column :requests, :target_user_id, :integer
    add_column :requests, :message, :text
  end
end
