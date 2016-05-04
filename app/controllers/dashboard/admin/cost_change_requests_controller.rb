class Dashboard::Admin::CostChangeRequestsController < Dashboard::Admin::BaseController
  before_action :initialize_cost_change_request!, only: [:confirm_reject, :reject, :confirm_approve, :approve]

  def index
    base_query = CostChangeRequest.pending.includes(:user).where(users: {is_profile_owner: true})
    @cost_change_requests = if params[:new_users]
                              base_query.where(old_cost: nil)
                            else
                              base_query.where.not(old_cost: nil)
                            end.order(created_at: :desc).page(params[:page]).per(100)

    if !@cost_change_requests.first_page? && @cost_change_requests.out_of_range?
      redirect_to admin_cost_change_requests_path(new_users: params[:new_users], page: @cost_change_requests.total_pages)
    else
      json_render
    end
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

  def bulk_process
    case params[:commit]
    when 'approve'
      Concerns::CostUpdatePerformer.approve_requests(params[:ids], update_existing_subscriptions: params.bool(:update_existing_subscriptions))
    when 'reject'
      Concerns::CostUpdatePerformer.reject_requests(params[:ids])
    else
      error(400)
    end
    json_reload
  rescue BulkEmptySetError => e
    json_reload notice: e.message
  end

  private

  def initialize_cost_change_request!
    @cost_change_request = CostChangeRequest.find(params[:id])
  end
end
