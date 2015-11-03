class Dashboard::RecentProfilesController < Dashboard::BaseController
  def index
    @users = User.profile_owners.where(has_complete_profile: true).order(created_at: :desc).page(params[:page]).per(100)
    json_render
  end
end
