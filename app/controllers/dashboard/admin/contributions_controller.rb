class Dashboard::Admin::ContributionsController < Dashboard::Admin::BaseController
  before_action :load_contribution!, only: [:confirm_cancel, :cancel]

  def index
    @months = Contribution.pluck("DISTINCT date_trunc('month', created_at)").sort

    @date = Chronic.parse(params[:month])
    @contributions = Contribution.all.includes(:user, :target_user, :parent).page(params[:page])

    if @date
      @contributions = @contributions.where(created_at: @date.beginning_of_month..@date.end_of_month).per(100)
    else
      @contributions.per(100)
    end

    json_render
  end

  def confirm_cancel
    json_popup
  end

  def cancel
    manager.cancel
    json_reload
  end

  private

  def manager
    ContributionManager.new(user: current_user.object, contribution: @contribution)
  end

  def load_contribution!
    @contribution = Contribution.find(params[:id])
  end
end
