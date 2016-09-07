class Dashboard::Admin::TosAcceptorsController < Dashboard::Admin::BaseController
  before_action :load_user!, only: [:confirm_toggle_tos_acceptance, :toggle_tos_acceptance, :history]

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_admin_fields
    json_replace
  end

  def index
    @users = Queries::Users.new(user: current_user.object, query: params[:q], page: params[:page]).by_tos_acceptance
    json_render
  end

  def confirm_toggle_tos_acceptance
    json_popup
  end

  def toggle_tos_acceptance
    UserManager.new(@user, current_user.object).toggle_tos_acceptance
    json_reload
  end

  def confirm_reset_tos_acceptance
    json_popup
  end

  def reset_tos_acceptance
    TosManager.new.reset_tos_acceptance
    json_reload
  end

  def history
    @acceptances = acceptances_for(@user)
    json_render
  end

  private

  def load_user!
    @user = User.find(params[:id])
  end

  def acceptances_for(user)
    TosVersion.published.joins("LEFT OUTER JOIN tos_acceptances ON tos_versions.id = tos_acceptances.tos_version_id AND tos_acceptances.user_id = #{user.id}")
        .order('tos_acceptances.created_at DESC NULLS LAST, tos_versions.published_at DESC')
        .select('tos_versions.published_at AS enabled_at, tos_acceptances.created_at AS accepted_at, tos_acceptances.user_email AS user_email, tos_acceptances.user_full_name AS user_full_name, tos_acceptances.performed_by_admin AS performed_by_admin')
  end
  helper_method :acceptances_for
end
