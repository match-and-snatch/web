class Dashboard::Admin::TosAcceptorsController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:confirm_toggle_tos_acceptance, :toggle_tos_acceptance]

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def index
    @users = User.where(tos_accepted: params[:accepted] || true).page(params[:page]).per(100)
    json_render
  end

  def confirm_toggle_tos_acceptance
    json_popup
  end

  def toggle_tos_acceptance
    UserManager.new(@user).toggle_tos_acceptance
    json_reload
  end

  def confirm_reset_tos_acceptance
    json_popup
  end

  def reset_tos_acceptance
    UserManager.reset_tos_acceptance
    json_reload
  end

  private

  def load_user!
    @user = User.find(params[:id])
  end
end
