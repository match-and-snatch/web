class Dashboard::Admin::SubscriptionsController < Dashboard::Admin::BaseController
  before_action :load_subscription!, only: [:confirm_deletion, :delete]

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def index
    query = Subscription.base_scope.includes(:user, :target_user)
    if params[:filter]
      query = query.where(params[:filter].slice(:user_id, :target_user_id))
    end
    @subscriptions = query.order(created_at: :desc).page(params[:page]).per(100)
    json_render
  end

  def confirm_deletion
    json_popup
  end

  def delete
    SubscriptionManager.new(subscription: @subscription).delete
    json_reload
  end

  private

  def load_subscription!
    @subscription = Subscription.base_scope.find(params[:id])
  end
end
