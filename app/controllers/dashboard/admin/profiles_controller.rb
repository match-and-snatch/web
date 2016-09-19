class Dashboard::Admin::ProfilesController < Dashboard::Admin::BaseController
  before_action :load_user!, only: %i[make_public make_private show toggle]

  def index
    @users = Queries::Users.new(user: current_user, query: params[:q], include_hidden: true).profile_owners_by_text
    json_replace
  end

  def public
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
