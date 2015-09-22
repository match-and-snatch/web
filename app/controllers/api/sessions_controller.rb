class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_by_api_token

  def create
    user = session_manager.login(params[:email], params[:password], use_api_token: true)
    json_success user: api_response.current_user_data(user)
  end
end
