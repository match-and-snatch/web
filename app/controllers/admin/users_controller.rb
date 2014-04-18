class Admin::UsersController < Admin::BaseController
  before_filter :load_user!, only: %i(make_admin drop_admin make_profile_public make_profile_private)

  def index
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).results
    json_replace
  end

  def profiles
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).profile_owners
    json_replace
  end

  def make_profile_public
    UserProfileManager.new(@user).make_profile_public
    json_replace
  end

  def make_profile_private
    UserProfileManager.new(@user).make_profile_private
    json_replace
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