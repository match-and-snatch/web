class RemoveSubscribersChart < ActiveRecord::Migration
  def change
    add_column :users, :subscriptions_chart_visible, :boolean, default: false, null: false

    update("UPDATE users set subscriptions_chart_visible = 't'")
  end
end
