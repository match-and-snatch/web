class Admin::ContributionsController < Admin::BaseController
  before_action :load_contribution!, only: [:confirm_destroy, :destroy]

  def index
    @months = Contribution.group("date_trunc('month', created_at)").count.to_a.sort_by(&:first)

    @date = Chronic.parse(params[:month])
    @contributions = Contribution.all.includes(:user, :target_user).page(params[:page])

    if @date
      @contributions = @contributions.where("contributions.created_at BETWEEN ? AND ? ", @date.beginning_of_month, @date.end_of_month).per(10000)
    else
      @contributions.per(100)
    end

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
