class Dashboard::Admin::PaymentsController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:pending]

  def index
    @users = User.joins(:source_payments).
      select('users.*, SUM(payments.amount) as amount').
      group('users.id, payments.amount').
      order('amount DESC')
    json_render
  end

  def pending
    day = Time.at(params[:date].to_i).to_date.prev_month
    @failed_payments = @user.source_subscriptions.
        not_removed.
        where(rejected: true).
        where(['rejected_at <= ?', day.next_month.end_of_day]).
        order(:rejected_at)

    @pending_payments = @user.source_subscriptions.
        includes(:user).
        not_removed.
        not_rejected.
        where(['charged_at <= ?', day.end_of_day]).
        order(:charged_at)
    json_popup
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end

  def month_range
    (Time.zone.now.beginning_of_month..Time.zone.now)
  end
end