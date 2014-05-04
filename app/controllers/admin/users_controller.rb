class Admin::UsersController < Admin::BaseController
  before_filter :load_user!, only: %i(make_admin drop_admin login_as)

  def index
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).results
    json_replace
  end

  def login_as
    session_manager.login_as(current_user.object, @user)
    json_redirect profile_path(@user)
  end

  def make_admin
    UserManager.new(@user).make_admin
    json_replace
  end

  def drop_admin
    UserManager.new(@user).drop_admin
    json_replace
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end