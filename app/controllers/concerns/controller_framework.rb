module Concerns::ControllerFramework
  extend ActiveSupport::Concern

  included do
    rescue_from ManagerError do |error|
      json_render_errors error.messages
    end

    rescue_from HttpCodeError do |error|
      process_http_code_error(error)
    end

    helper_method :can?
    helper_method :current_user
  end

  module ClassMethods
    def protect(*actions, &block)
      filter_options = actions.any? ? [{only: actions}] : []
      before_filter(*filter_options) { instance_eval(&block) or error(401) }
    end
  end

  # Returns a new kind of ActionController::Parameters object that
  # has been instantiated with the <tt>request.parameters</tt>.
  # @return [ActionController::ManagebleParameters]
  def params
    @_params ||= ActionController::ManagebleParameters.new(request.parameters)
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

  # @return [CurrentUserDecorator]
  def current_user
    session_manager.current_user
  end

  # @param code [Integer]
  def error(code)
    raise HttpCodeError, code
  end

  # @return [SessionManager]
  def session_manager
    @session_manager ||= SessionManager.new(cookies)
  end

  # @param error [HttpCodeError]
  def process_http_code_error(error)
    respond_to do |wants|
      wants.json do
        json_response error.code, {}, error.code
      end

      wants.any do
        response.headers["Content-Type"] = "text/html"
        render status: error.code, template: "errors/#{error.code}", layout: 'application', formats: [:html]
      end
    end
  end

  def json_response(status, data = {}, response_status = 200)
    resp = {status: status, token: form_authenticity_token}.reverse_merge(data)

    if resp[:notice].is_a? Symbol
      resp[:notice] = translate_message(resp[:notice])
    end
    resp[:notice] ||= @notice if @notice

    render json: resp, status: response_status
  end

  # Notifies client side about failed operation
  # @param response_params [Hash]
  def json_fail(response_params = {})
    json_response 'failed', response_params
  end

  # Renders failed response with errors hash
  # @param errors [Hash]
  def json_render_errors(errors)
    json_fail errors
  end

  # Notifies client side of successful action
  # @param response_params [Hash]
  def json_success(response_params = {})
    json_response 'success', response_params
  end
end