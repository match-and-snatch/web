class Admin::ProfileOwnersController < Admin::BaseController
  before_action :load_user!, only: [:show, :total_subscribed, :total_new_subscribed,
                                    :total_unsubscribed, :failed_billing_subscriptions,
                                    :pending_payments, :this_month_subscribers_unsubscribers]

  def index
    query = User.profile_owners.includes(:profile_types).where('users.subscription_cost IS NOT NULL').limit(1000)
    query = query.joins(:source_payments).
      select('users.*, SUM(payments.amount) as transfer').
      group('users.id')
    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order('transfer DESC')
    end
    @users = query.map { |user| ProfileDecorator.new(user) }
    json_render
  end

  def show
    json_render
  end

  def update
    @user = User.where(id: params[:id]).first or error(404)
    @user.update_attributes!(params.require(:user).permit(:custom_profile_page_css))
    json_success notice: 'CSS Updated Successfully'
  end

  def total_subscribed
    @subscriptions = Subscription.
      includes(:user).
      where(users: { billing_failed: false }).
      where(target_user_id: @user.id).
      where(["removed_at > ? OR removed = 'f'", period.end]).
      where(['subscriptions.created_at <= ?', period.end]).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  def total_new_subscribed
    @subscriptions = @user.object.
        source_subscriptions.
        includes(:user).
        where(created_at: period).
        where.not(user_id: nil).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  def total_unsubscribed
    @subscriptions = Subscription.
        where(target_user_id: @user.id, removed_at: period, removed: true).
        where.not(user_id: nil).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  def this_month_subscribers_unsubscribers
    @subscriptions = Subscription.
        where(target_user_id: @user.id, removed_at: period, removed: true, created_at: period).
        where.not(user_id: nil).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  def failed_billing_subscriptions
    @users = User.
        joins(:subscriptions).
        where(subscriptions: {target_user_id: @user.id}, billing_failed_at: period)
    json_popup
  end

  def pending_payments
    @subscriptions = @user.object.
        source_subscriptions.not_removed.
        where(charge_date: period, rejected: false).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  private

  def date
    Time.zone.parse(params[:date])
  end

  def period
    date.beginning_of_month..date
  end

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
    @user = UserStatsDecorator.new(@user)
  end
end
