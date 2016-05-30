class Dashboard::UsersController < Dashboard::BaseController
  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def login_as
    session_manager.login_as(current_user.object, @user)

    if @user.billing_failed?
      notice :billing_failed
      json_redirect account_info_url(anchor: '/account_info/billing_information')
    else
      path = if @user.has_profile_page?
               profile_path(@user)
             else
               anchor = '/subscriptions' if @user.subscriptions.any?
               account_info_path(anchor: anchor)
             end
      json_redirect path
    end
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
