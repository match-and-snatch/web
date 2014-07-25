class FillRejectedColumnForSubscriptions < ActiveRecord::Migration
  def up
    Subscription.where(charged_at: nil).find_each do |subscription|
      subscription.rejected = true
      subscription.rejected_at = subscription.payment_failures.first.try(:created_at) || subscription.created_at
      subscription.save
    end
    Subscription.where.not(charged_at: nil).joins(:payment_failures).readonly(false).uniq.find_each do |subscription|
      payment_failure = subscription.payment_failures.where(['created_at > ?', subscription.charged_at]).first
      if payment_failure
        subscription.rejected = true
        subscription.rejected_at = payment_failure.created_at
        subscription.save
      end
    end
  end

  def down
  end
end
