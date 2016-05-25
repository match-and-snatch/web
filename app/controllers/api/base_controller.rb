class Api::BaseController < ActionController::Base
  include Concerns::ControllerFramework

  rescue_from(AuthenticationError) { |e| json_response 'failed', e.messages }

  skip_before_action :verify_authenticity_token, :redirect_to_mobile!
  before_action :allow_cors, :authenticate_by_api_token

  protected

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
  end

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
  def json_response(status, data = {}, api_token = nil, response_status = 200)
    super(status, {data: data, current_user: api_response.basic_current_user_data, api_token: api_token, api_version: APP_CONFIG['api_version']}, response_status)
  end

  # @param error [HttpCodeError]
  def process_http_code_error(error)
    json_response error.code, {}, error.code
  end

  private

  def auth_token
    return @token if defined?(@token)
    authenticate_with_http_token { |t, _| @token = t }
    @token
  end

  def api_response
    @api_response ||= ApiResponsePresenter.new(current_user)
  end
end
