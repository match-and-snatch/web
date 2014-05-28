class AddCostsToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :user_cost, :integer
    add_column :payments, :user_subscription_fees, :float
    add_column :payments, :user_subscription_cost, :float

    Payment.reset_column_information

    Payment.find_each do |payment|
      if payment.target_user
        payment.user_cost = payment.target_user.cost
        payment.user_subscription_fees = payment.target_user.subscription_fees
        payment.user_subscription_cost = payment.target_user.subscription_cost
        payment.save!
      end
    end
  end
end
