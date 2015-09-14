class Admin::ProfileOwnersController < Admin::BaseController
  before_action :load_user!, only: [:show, :update, :change_fake_subscriptions_number, :total_subscribed,
                                    :total_new_subscribed, :total_unsubscribed, :failed_billing_subscriptions,
                                    :pending_payments, :this_month_subscribers_unsubscribers]

  def index
    query = User.profile_owners.includes(:profile_types).where('users.subscription_cost IS NOT NULL')
    query = query.joins(:source_payments).
      select('users.*, SUM(payments.amount) as transfer').
      group('users.id')
    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order('transfer DESC')
    end

    @users = ProfileDecorator.decorate_collection(query.page(params[:page]).per(20))

    json_render
  end

  def show
    @user = UserStatsDecorator.new(@user)
    json_render
  end

  def update
    @user.update_profile_page!(params.require(:profile_page).permit(:css, :welcome_box, :special_offer))
    json_success notice: 'Profile page customization updated successfully'
  end

  def change_fake_subscriptions_number
    SubscriptionManager.create_fakes(count: params[:count], target_user: @user)
    json_reload notice: 'Fake Subscriptions Were Successfully Added'
  end

  def total_subscribed
    @subscriptions = @user.
        source_subscriptions.
        includes(:user).
        where(users: { billing_failed: false }).
        where(["removed_at > ? OR removed = 'f'", period.end]).
        where(['subscriptions.created_at <= ?', period.end]).
        order(:charged_at).map { |s| SubscriptionDecorator.new(s, date) }
    json_popup
  end

  def total_new_subscribed
    @subscriptions = @user.
        source_subscriptions.
        includes(:user).
        where(created_at: period).
        where.not(user_id: nil).
        order(:charged_at)
    json_popup
  end

  def total_unsubscribed
    @subscriptions = @user.
        source_subscriptions.
        includes(:user).
        where(removed_at: period, removed: true).
        where.not(user_id: nil).
        order(:removed_at)
    json_popup
  end

  def this_month_subscribers_unsubscribers
    @subscriptions = @user.
        source_subscriptions.
        includes(:user).
        where(removed_at: period, removed: true, created_at: period).
        where.not(user_id: nil).
        order(:removed_at)
    json_popup
  end

  def failed_billing_subscriptions
    @users = User.
        joins(:subscriptions).
        where(subscriptions: {target_user_id: @user.id}, billing_failed_at: period)
    json_popup
  end

  def pending_payments
    @subscriptions = @user.
        source_subscriptions.
        includes(:user).
        not_removed.
        not_rejected.
        where(["(charged_at + INTERVAL '1 month') BETWEEN ? AND ?", period.begin, period.end]).
        order(:charged_at)
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
  end
end
