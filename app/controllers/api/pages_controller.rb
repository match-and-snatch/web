class Api::PagesController < Api::BaseController
  def terms_of_service
    json_success api_response.tos_data
  end
end
