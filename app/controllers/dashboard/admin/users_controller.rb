class Dashboard::Admin::UsersController < Dashboard::UsersController
  include Dashboard::Concerns::AdminController

  before_action :load_user!, only: %i(make_admin drop_admin make_sales drop_sales login_as)

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
end
