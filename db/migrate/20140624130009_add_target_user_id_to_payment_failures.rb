class AddTargetUserIdToPaymentFailures < ActiveRecord::Migration
  def change
    add_column :payment_failures, :target_user_id, :integer

    PaymentFailure.find_each do |pf|
      if pf.target
        pf.target_user_id = pf.target.target_user.id
        pf.save!
      end
    end
  end
end
