class Admin::CostChangeRequestsController < Admin::BaseController
  before_action :initialize_cost_change_request!, only: [:confirm_reject, :reject, :confirm_approve, :approve]

  def index
    @cost_change_requests = CostChangeRequest.pending.limit(100).to_a
    json_render
  end

  def confirm_reject
    json_popup
  end

  def reject
    @cost_change_request.reject!
    json_reload
  end

  def confirm_approve
    json_popup
  end

  def approve
    @cost_change_request.approve!
    json_reload
  end

  private

  def initialize_cost_change_request!
    @cost_change_request = CostChangeRequest.find(params[:id])
  end
end
