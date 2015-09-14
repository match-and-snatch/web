class Admin::BansController < Admin::BaseController

  def index
    @users = User.where(locked: true).order(updated_at: :desc).all
    json_render
  end

  def search
    @users = User.where(email: params[:q].try(:strip))
    json_replace
  end

  def create
    UserManager.new(User.where(email: params[:email]).first).lock
    json_reload
  end

  def destroy
    user = User.find(params[:id])
    UserManager.new(user).unlock
    json_reload
  end
end
