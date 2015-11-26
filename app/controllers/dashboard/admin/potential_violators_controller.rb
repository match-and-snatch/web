class Dashboard::Admin::PotentialViolatorsController < Dashboard::Admin::BaseController

  def index
    @users = User.joins(:subscriptions)
      .includes(subscriptions: :target_user)
      .group('users.id').having('COUNT(subscriptions.id) >= 8')
      .order(recent_subscription_at: :desc)
      .page(params[:page]).per(20)

    json_render
  end
end
