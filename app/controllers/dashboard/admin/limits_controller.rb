class Dashboard::Admin::LimitsController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:edit, :update, :events]

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def index
    @users = User.where.not(adult_subscriptions_limit: 6)
               .order(adult_subscriptions_limit_changed_at: :desc)
               .page(params[:page]).per(100)
    json_render
  end

  def edit
    json_popup
  end

  def update
    UserManager.new(@user).update_adult_subscriptions_limit(params[:limit])
    json_reload notice: "Subscriptions limit has been changed for #{@user.name}"
  end

  def events
    @events = @user.events.where(action: 'subscriptions_limit_changed').order(created_at: :desc)
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
