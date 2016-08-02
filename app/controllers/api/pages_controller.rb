class Api::PagesController < Api::BaseController
  def terms_of_service
    json_success terms_of_service: TosVersion.active.tos
  end
end
