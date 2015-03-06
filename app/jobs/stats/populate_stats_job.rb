module Stats
  class PopulateStatsJob
    def self.perform
      User.profile_owners.where.not(subscription_cost: nil).find_each do |user|
        UserStatsManager.new(user).log_subscriptions_count
      end
    end
  end
end
