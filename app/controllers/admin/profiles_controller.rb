class Admin::ProfilesController < Admin::BaseController
  before_filter :load_user!, only: %i(make_public make_private)

  def index
    @users = User.profile_owners.search_by_full_name(params[:q]).limit(10)
    json_replace
  end

  def profile_owners
    @users = User.profile_owners.limit(200)
    json_render
  end

  def new
    @users = User.where(has_public_profile: true).order(:full_name).limit(200).to_a
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