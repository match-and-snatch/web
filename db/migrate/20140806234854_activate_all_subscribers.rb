class ActivateAllSubscribers < ActiveRecord::Migration
  def up
    puts "Total users: #{User.count}, updated: "
    puts User.joins(:subscriptions).update_all(activated: true)
  end
end
