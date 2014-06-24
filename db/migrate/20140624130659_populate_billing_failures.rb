class PopulateBillingFailures < ActiveRecord::Migration
  def change
    User.where(billing_failed: true).update_all({billing_failed_at: Time.zone.now})
  end
end
