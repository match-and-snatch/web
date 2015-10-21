class Dashboard::Admin::BansController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:destroy, :unsubscribe]

  def index
    @users = User.select("users.*, COUNT(subscriptions.id) as not_removed_subscriptions_count")
      .joins("LEFT OUTER JOIN subscriptions ON users.id = subscriptions.user_id AND subscriptions.removed = 'f'")
      .where(locked: true)
      .group('users.id')
      .order(last_time_locked_at: :desc)
      .page(params[:page]).per(100)
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def create
    UserManager.new(User.where(email: params[:email]).first).lock(params[:reason])
    json_reload
  end

  def destroy
    UserManager.new(@user).unlock
    json_reload
  end

  def unsubscribe
    SubscriptionManager.new(subscriber: @user).unsubscribe_entirely
    json_reload
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
