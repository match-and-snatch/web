class Admin::CostChangeRequestsController < Admin::BaseController
  before_filter :initialize_cost_change_request!, only: [:confirm_reject, :reject]

  def index
    @cost_change_requests = CostChangeRequest.active.limit(100).to_a
    json_render
  end

  def confirm_reject
    json_popup
  end

  def reject
    @cost_change_request.reject!
    json_reload
  end

  private

  def initialize_cost_change_request!
    @cost_change_request = CostChangeRequest.find(params[:id])
  end
end
