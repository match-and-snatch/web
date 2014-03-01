class ApplicationController < ActionController::Base

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  if ___access_config = APP_CONFIG['http_access']
    http_basic_authenticate_with ___access_config.symbolize_keys
  end

  # @param action [Symbol]
  # @param callbacks [Array<Symbol>]
  def self.before(action, *callbacks)
    self.before_filter(*callbacks, only: action)
  end

  protected

  # @param code [Integer]
  def error(code)
    render status: code, text: code.inspect
  end

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
    json_fail errors: errors
  end

  # @param _action [String]
  def json_render(_action = action_name)
    render json: {status: 'success', html: render_to_string(action: _action, layout: false, formats: [:html])}
  end

  # @param _action [String]
  def json_replace(_action = action_name)
    render json: {status: 'replace', html: render_to_string(action: _action, layout: false, formats: [:html])}
  end
end
