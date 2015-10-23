class Dashboard::Admin::UsersController < Dashboard::UsersController
  include Dashboard::Concerns::AdminController

  before_action :load_user!, only: %i(make_admin drop_admin make_sales drop_sales login_as)

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

  def make_sales
    UserManager.new(@user).make_sales
    json_replace
  end

  def drop_sales
    UserManager.new(@user).drop_sales
    json_replace
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
