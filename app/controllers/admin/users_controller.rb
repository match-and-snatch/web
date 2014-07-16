class Admin::UsersController < Admin::BaseController
  before_filter :load_user!, only: %i(make_admin drop_admin login_as)

  def index
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def login_as
    session_manager.login_as(current_user.object, @user)

    if @user.billing_failed?
      notice :billing_failed
      json_redirect account_info_url(anchor: '/account_info/billing_information')
    else
      json_redirect @user.has_profile_page? ? profile_path(@user) : account_info_path
    end
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
