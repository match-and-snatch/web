class Dashboard::Admin::BansController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:destroy, :unsubscribe]

  def index
    @users = User.where(locked: true).order(updated_at: :desc).page(params[:page]).per(100)
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
