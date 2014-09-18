module Subscriptions
  class DuplicateRemovalJob

    def self.perform
      sql = <<-SQL
        EXISTS (SELECT * FROM subscriptions sub
                WHERE subscriptions.id <> sub.id
                AND subscriptions.user_id = sub.user_id
                AND subscriptions.target_user_id = sub.target_user_id)
      SQL
      Subscription.where([sql]).group_by {|subscription| subscription.user }.each do |user, sbscrptns|
        sbscrptns.group_by { |subscription| subscription.target_user_id }.each do |target_user_id, subscriptions|
          master_subscription = user.subscriptions.where(target_user_id: target_user_id, removed: false, rejected: false).first ||
              user.subscriptions.where(target_user_id: target_user_id, removed: false, rejected: true).first ||
              user.subscriptions.where(target_user_id: target_user_id).first

          ids = subscriptions.map(&:id) - [master_subscription.id]
          Payment.where(target_type: 'Subscription', target_id: ids).update_all(target_id: master_subscription.id)
          PaymentFailure.where(target_type: 'Subscription', target_id: ids).update_all(target_id: master_subscription.id)
          Subscription.where(id: ids).delete_all
        end
      end
    end
  end
end