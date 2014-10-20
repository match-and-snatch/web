module Events
  class PopulateWithoutUsersJob
    def self.perform
      Subscription.where.not(user_id: User.select(:id)).each do |subscription|
        EventsManager.subscription_cancelled(user: nil, subscription: subscription) do |event|
          event.created_at = subscription.created_at
          event.updated_at = subscription.created_at
          event.user_id = subscription.user_id
        end
        EventsManager.subscription_created(user: nil, subscription: subscription) do |event|
          event.created_at = subscription.created_at
          event.updated_at = subscription.created_at
          event.user_id = subscription.user_id
        end
        subscription.delete
      end

      Subscription.joins(:user).where(removed: true).each do |subscription|
        EventsManager.subscription_cancelled(user: subscription.user, subscription: subscription) do |event|
          event.created_at = subscription.removed_at
          event.updated_at = subscription.removed_at
        end
      end
    end
  end
end