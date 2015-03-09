class Admin::CurrentMonthDetailsController < Admin::BaseController
  before_action :load_user!

  def index
    @current_month = CurrentMonthPresenter.new(user: @user)
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end
end
