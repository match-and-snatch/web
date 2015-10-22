class Dashboard::UsersController < Dashboard::BaseController
  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end
end
