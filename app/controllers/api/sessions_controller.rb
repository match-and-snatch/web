class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_by_api_token

  def create
    user = session_manager.login(params[:email], params[:password], use_api_token: true)
    json_success api_token: user.api_token
  end
end
