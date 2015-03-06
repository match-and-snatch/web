class Admin::VacationsController < Admin::BaseController
  before_filter :load_user!

  def index
    @vacations = VacationsPresenter.new(user: @user)
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end
end
