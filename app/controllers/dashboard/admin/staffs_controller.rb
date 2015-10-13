class Dashboard::Admin::StaffsController < Dashboard::Admin::BaseController

  def index
    @users = User.admins.limit(200).to_a
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_email
    json_replace
  end
end