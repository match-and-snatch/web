class Admin::ContributionRequestsController < Admin::BaseController
  before_action :initialize_contribution_request!, only: [:confirm_reject, :reject, :confirm_approve, :approve]

  def index
    @contribution_requests = ContributionRequest.pending.limit(100).to_a
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

  def initialize_contribution_request!
    @contribution_request = ContributionRequest.find(params[:id])
  end
end
