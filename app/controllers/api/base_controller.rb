class Api::BaseController < ActionController::Base
  include Concerns::ControllerFramework

  rescue_from(AuthenticationError) { |e| json_response 'failed', {message: e.message}, 401 }

  skip_before_filter :verify_authenticity_token
  before_filter :authenticate_by_api_token

  protected

  # @return [CurrentUserDecorator]
  def authenticate_by_api_token
    authenticate_by_api_token! if auth_token
    current_user
  end

  # @return [CurrentUserDecorator]
  # @raise [AuthenticationError]
  def authenticate_by_api_token!
    auth_manager = AuthenticationManager.new(api_token: auth_token)
    @current_user = CurrentUserDecorator.new(auth_manager.authenticate_api)
  end

  # @return [CurrentUserDecorator]
  def current_user
    @current_user ||= CurrentUserDecorator.new
  end

  # @override [Concerns::ControllerFramework]
  def json_response(status, data = {}, response_status = 200)
    super(status, {data: data}, response_status)
  end

  private

  def auth_token
    return @token if defined?(@token)
    authenticate_with_http_token { |t, _| @token = t }
    @token
  end
end