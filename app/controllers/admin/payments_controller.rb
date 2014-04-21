class Admin::PaymentsController < Admin::BaseController

  def index
    @users = User.joins(:source_payments).select('users.*, SUM(payments.amount) as amount').group('users.id, payments.amount').order('amount DESC')
    json_render
  end

  private

  def month_range
    (Time.zone.now.beginning_of_month..Time.zone.now)
  end
end