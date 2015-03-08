class Api::BaseController < ActionController::Base
  include Concerns::ControllerFramework

  rescue_from(AuthenticationError) { |e| json_response 'failed', {message: e.message}, 401 }

  skip_before_filter :verify_authenticity_token

  before_filter :authenticate_by_api_token!

  protected

  def authenticate_by_api_token!
    token = nil
    authenticate_with_http_token { |t, _| token = t }

    auth_manager = AuthenticationManager.new(api_token: token)
    @current_user = CurrentUserDecorator.new(auth_manager.authenticate_api)
  end

  # @return [CurrentUserDecorator]
  def current_user
    @current_user ||= CurrentUserDecorator.new
  end
end