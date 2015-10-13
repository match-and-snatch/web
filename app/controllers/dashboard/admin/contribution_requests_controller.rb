class Dashboard::Admin::ContributionRequestsController < Dashboard::Admin::BaseController
  before_action :load_contribution_request!, only: [:confirm_reject, :reject, :confirm_approve, :approve]

  def index
    @contribution_requests = ContributionRequest.pending.order(created_at: :desc).page(params[:page]).per(100)
    json_render
  end

  def confirm_reject
    json_popup
  end

  def reject
    @contribution_request.reject!
    json_reload
  end

  def confirm_approve
    json_popup
  end

  def approve
    ContributionManager.new(user: @contribution_request.user).approve!(@contribution_request)
    json_reload
  end

  private

  def load_contribution_request!
    @contribution_request = ContributionRequest.find(params[:id])
  end
end
