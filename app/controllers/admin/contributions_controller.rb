class Admin::ContributionsController < Admin::BaseController
  before_action :load_contribution!, only: [:confirm_destroy, :destroy]

  def index
    @contributions = Contribution.all.includes(:user, :target_user).page(params[:page]).per(100)
    json_render
  end

  def confirm_destroy
    json_popup
  end

  def destroy
    ContributionManager.new(user: current_user.object, contribution: @contribution).delete
    json_reload
  end

  private

  def load_contribution!
    @contribution = Contribution.find(params[:id])
  end
end
