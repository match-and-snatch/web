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

  def self.protect(*actions, &block)
    filter_options = actions.any? ? [{only: actions}] : []
    before_filter(*filter_options) { instance_eval(&block) or error(401) }
  end

  protected

  # Restricts public access
  def authenticate!
    current_user.authorized? or error(401)
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

  # @param code [Integer]
  def error(code)
    raise HttpCodeError, code
  end

  # Redirects page on response via JS
  # @param url [String] to redirect to
  def json_redirect(url)
    render json: { status: 'redirect', url: url }
  end

  # Notifies client side about failed operation
  # @param response_params [Hash]
  def json_fail(response_params = {})
    render json: { status: 'failed' }.merge(response_params)
  end

  # Renders failed response with errors hash
  # @param errors [Hash]
  def json_render_errors(errors)
    json_fail errors
  end

  # Notifies client side of successful action
  # @param response_params [Hash]
  def json_success(response_params = {})
    render json: {status: 'success'}.merge(response_params)
  end

  # Renders html with success status
  # @param json [Hash]
  def json_render(json = {})
    json_render_html('success', json)
  end

  # Appends html to container
  # @param json [Hash]
  def json_append(json = {})
    json_render_html('append', json)
  end

  # Prepends html to container
  # @param json [Hash]
  def json_prepend(json = {})
    json_render_html('prepend', json)
  end

  # Replaces container with responded html
  # @param json [Hash]
  def json_replace(json = {})
    json_render_html('replace', json)
  end

  # Reloads page via JS
  def json_reload
    render json: {status: 'reload'}
  end

  # @param status [String]
  # @param json [Hash]
  # @option json [String, nil] :template
  def json_render_html(status, json = {})
    unless json[:html]
      template = json.delete(:template) || action_name
      json[:html] = render_to_string(action: template, layout: false, formats: [:html])
    end

    render json: json.merge(status: status)
  end

  # @return [SessionManager]
  def session_manager
    @session_manager ||= SessionManager.new(session)
  end
end
