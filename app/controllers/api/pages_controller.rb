class Api::PagesController < Api::BaseController
  def terms_of_service
    json_success api_response.tos_data
  end

  def privacy_policy
    json_success api_response.privacy_policy_data
  end
end
