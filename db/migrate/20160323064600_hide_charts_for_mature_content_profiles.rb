class HideChartsForMatureContentProfiles < ActiveRecord::Migration
  def up
    User.where(has_mature_content: true).update_all(subscriptions_chart_visible: false)
  end

  def down

  end
end
