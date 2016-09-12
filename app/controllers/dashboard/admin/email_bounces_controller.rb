class Dashboard::Admin::EmailBouncesController < Dashboard::Admin::BaseController

  def index
    @users = User.where.not(email_bounced_at: nil).order(:email_bounced_at).page(params[:page]).per(50)
    json_render
  end
end
