class ApplicationController < ActionController::Base
  HANDLERS = []

  def self.create_handler(*types)
    types.each do |type|
      HANDLERS << type.to_s

      define_singleton_method type do |name, &block|
        unless method_defined?(name)
          define_method(name) { handle_request(name, type, &block) }
        end
      end
    end
  end

  create_handler :plain_html, :popup

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from HttpCodeError do |error|
    respond_to do |wants|
      wants.html do
        response.headers["Content-Type"] = "text/html"
        render status: error.code, template: "errors/#{error.code}", layout: 'application', formats: [:html]
      end

      wants.any do
        json_response error.code, {}, error.code
      end
    end
  end

  protected

  def layout
    @layout ||= {}
  end
  helper_method :layout

  # @param code [Integer]
  def error(code)
    raise HttpCodeError, code
  end

  # Notifies client side about failed operation
  # @param response_params [Hash]
  def json_fail(response_params = {})
    json_response 'failed', response_params
  end

  # Redirects page on response via JS
  # @param url [String] to redirect to
  # @param notice [String, Symbol]
  def json_redirect(url, notice: nil)
    self.notice(notice) if notice
    json_response 'redirect', url: url
  end

  # Reloads page via JS
  # @param notice [String, Symbol]
  def json_reload(notice: nil)
    self.notice(notice) if notice
    json_response 'reload'
  end

  # @param message [Symbol] i18n Identifier
  def notice(message, opts = {})
    if message.is_a?(Symbol)
      message = translate_message(message, opts)
      @notice = message
      flash.notice = message
    elsif message.is_a?(String)
      @notice = message
      flash.notice = message
    end
  end

  def pass_flow(flow, &block)
    if block.try(:arity) == 1
      block.call(flow)
    elsif flow.passed?
      block.call if block
    else
      json_fail errors: flow.errors
    end
  end

  private

  def handle_request(name, type, &block)
    instance_eval(&block) if block
    type = params[:mode] || type.to_s

    if HANDLERS.include?(type)
      json_response 'success', {type => render_to_string(action: "#{type}/#{name}", layout: type, formats: [:html])}
    else
      json_response 400, {message: :invalid_mode}, 400
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

  def translate_message(message, opts = {})
    raise ArgumentError unless message.is_a? Symbol
    I18n.t(message, opts.reverse_merge(scope: :messages, default: [:default, message])).html_safe
  end
end
