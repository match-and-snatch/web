class IncreaseAdultSubscriptionsLimitForLockedUsers < ActiveRecord::Migration
  def change
    reversible do |direction|
      direction.up do
        [4, 5, 6].each do |i|
          User.joins(subscriptions: :target_user)
              .where(target_users_subscriptions: {has_mature_content: true}, users: {locked: true})
              .group('users.id')
              .having("COUNT(subscriptions.id) = #{i}")
              .update_all(locked: false, adult_subscriptions_limit: i + 2)
        end
      end
    end
  end
end
