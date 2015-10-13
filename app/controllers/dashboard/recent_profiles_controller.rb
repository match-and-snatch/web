class Dashboard::RecentProfilesController < Dashboard::BaseController
  def index
    @users = User.profile_owners.order('created_at DESC').page(params[:page]).per(100)
    json_render
  end
end
