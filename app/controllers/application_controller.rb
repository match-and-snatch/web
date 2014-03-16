class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  if ___access_config = APP_CONFIG['http_access']
    http_basic_authenticate_with ___access_config.symbolize_keys
  end

  rescue_from ManagerError do |error|
    json_render_errors error.messages
  end

  rescue_from HttpCodeError do |error|
    render status: error.code, template: "errors/#{error.code}", layout: 'application'
  end

  # @param action [Symbol]
  # @param callbacks [Array<Symbol>]
  def self.before(action, *callbacks)
    self.before_filter(*callbacks, only: action)
  end

  protected

  # Restricts public access
  def authenticate!
    session_manager.current_user.authorized? or error(401)
  end

  # @param code [Integer]
  def error(code)
    raise HttpCodeError, code
  end

  # @param action [Symbol]
  # @param subject
  # @raise [ArgumentError] if action or subject are not registered
  # @return [true, false]
  def can?(action, subject)
    current_user.can?(action, subject)
  end
  helper_method :can?

  # @return [CurrentUserDecorator]
  def current_user
    session_manager.current_user
  end
  helper_method :current_user

  # @return [SessionManager]
  def session_manager
    @session_manager ||= SessionManager.new(session)
  end

  # @param url [String] to redirect to
  def json_redirect(url)
    render json: { status: 'redirect', url: url }
  end

  # @param response_params [Hash]
  def json_fail(response_params = {})
    render json: { status: 'failed' }.merge(response_params)
  end

  # @param errors [Hash]
  def json_render_errors(errors)
    json_fail errors
  end

  # @param response_params [Hash]
  def json_success(response_params = {})
    render json: {status: 'success'}.merge(response_params)
  end

  # @param _action [String]
  def json_render(_action = action_name, opts = {})
    json = {html: render_to_string(action: _action, layout: false, formats: [:html])}
    json_success json.merge(opts)
  end

  # @param _action [String]
  def json_append(_action = action_name, opts = {})
    json = {status: 'append', html: render_to_string(action: _action, layout: false, formats: [:html])}
    render json: json.merge(opts)
  end

  # @param _action [String]
  def json_prepend(_action = action_name, opts = {})
    json = {status: 'prepend', html: render_to_string(action: _action, layout: false, formats: [:html])}
    render json: json.merge(opts)
  end

  # @param _action [String]
  def json_replace(_action = action_name, opts = {})
    json = {status: 'replace', html: render_to_string(action: _action, layout: false, formats: [:html])}
    render json: json.merge(opts)
  end

  def json_reload
    render json: {status: 'reload'}
  end
end
