class Admin::PayoutDetailsController < Admin::BaseController

  def index
    @users = User.joins(:source_payments).
      select('users.*, SUM(payments.user_subscription_cost) as amount,
                       SUM(payments.user_subscription_fees) as connectpal_fees,
                       SUM(payments.user_cost) as payout_amount').
      group('users.id, payments.amount').
      order('amount DESC').
      where('amount > 1')
    json_render
  end
end
