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
    UserProfileManager.new(@cost_change_request.user).rollback_cost!(@cost_change_request, cost: params[:cost])
    json_reload
  end

  def confirm_approve
    json_popup
  end

  def approve
    UserProfileManager.new(@cost_change_request.user).approve_and_change_cost!(@cost_change_request, update_existing_subscriptions: params[:update_existing_subscriptions])
    json_reload
  end

  private

  def initialize_cost_change_request!
    @cost_change_request = CostChangeRequest.find(params[:id])
  end
end
