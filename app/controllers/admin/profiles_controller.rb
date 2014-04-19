class Admin::ProfilesController < Admin::BaseController
  before_filter :load_user!, only: %i(make_public make_private)

  def index
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).profile_owners
    json_replace
  end

  def new
    json_render
  end

  def make_public
    UserProfileManager.new(@user).make_profile_public
    json_replace
  end

  def make_private
    UserProfileManager.new(@user).make_profile_private
    json_replace
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end