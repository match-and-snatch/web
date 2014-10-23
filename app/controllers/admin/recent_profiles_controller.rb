class Admin::RecentProfilesController < Admin::BaseController
  def index
    @users = User.profile_owners.order('created_at DESC').limit(200)
    json_render
  end
end
