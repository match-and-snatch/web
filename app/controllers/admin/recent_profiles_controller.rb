class Admin::RecentProfilesController < Admin::BaseController
  def index
    @users = User.profile_owners.order('created_at DESC').page(params[:page]).per(30)
    json_render
  end
end
