class Admin::DeleteProfilePageRequestsController < Admin::BaseController
  before_action :initialize_delete_profile_page_request!, only: [:confirm_reject, :reject, :confirm_approve, :approve]

  def index
    @delete_profile_page_requests = DeleteProfilePageRequest.pending.limit(100).to_a
    json_render
  end

  def confirm_reject
    json_popup
  end

  def reject
    @delete_profile_page_request.reject!
    json_reload
  end

  def confirm_approve
    json_popup
  end

  def approve
    UserProfileManager.new(@delete_profile_page_request.user).delete_profile_page!
    @delete_profile_page_request.approve!
    json_reload
  end

  private

  def initialize_delete_profile_page_request!
    @delete_profile_page_request = DeleteProfilePageRequest.find(params[:id])
  end
end
