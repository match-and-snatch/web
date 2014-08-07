class ChangeCosts < ActiveRecord::Migration
  def up
    User.profile_owners.where.not(slug: 'dark-secret-place', cost: nil).find_each do |user|
      old_subscription_fees = user.subscription_fees
      old_subscription_cost = user.subscription_cost
      user.cost = user.cost
      puts "Changed #{user.slug} cost (#{user.cost}) from fee: #{old_subscription_fees} cost: #{old_subscription_cost} -> to fee: #{user.subscription_fees}, clear cost: #{user.subscription_cost}"
      user.save!
    end
  end
end
