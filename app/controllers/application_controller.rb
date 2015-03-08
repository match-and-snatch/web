class ApplicationController < ActionController::Base
  include Concerns::ControllerFramework

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  if ___access_config = APP_CONFIG['http_access']
    http_basic_authenticate_with ___access_config.symbolize_keys
  end

  before_filter do
    if current_user.billing_failed? && referrer_host != request.host
      notice(:billing_failed)
    end
  end

  protected

  # @return [User] authenticated user
  def request_basic_http_auth!
    viewer = authenticate_with_http_basic do |u, p|
      begin
        session_manager.login(u, p)
      rescue ManagerError
      end
    end

    unless viewer
      request_http_basic_authentication
    end

    viewer
  end

  def tablet_device?
    request_variant.include?(:tablet)
  end

  def mobile_phone_device?
    request_variant.include?(:phone)
  end
  helper_method :mobile_phone_device?

  def mobile_device?
    tablet_device? || mobile_phone_device?
  end
  helper_method :mobile_device?

  def layout
    @layout ||= Layout.new
  end
  helper_method :layout

  def set_layout(key, val = nil, &block)
    layout[key.to_sym] = val || capture(&block)
  end
  helper_method :set_layout

  # Redirects page on response via JS
  # @param url [String] to redirect to
  # @param notice [String, Symbol]
  def json_redirect(url, notice: nil)
    self.notice(notice) if notice
    json_response 'redirect', url: url
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

  # @param [String, Symbol]
  def json_popup(json = {})
    unless json[:popup]
      template = json.delete(:template) || action_name
      json[:popup] = render_to_string(action: template, layout: false, formats: [:html])
    end
    json_response 'success', json
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
  # @param notice [String, Symbol]
  def json_reload(notice: nil)
    self.notice(notice) if notice
    json_response 'reload'
  end

  # @param status [String]
  # @param json [Hash]
  # @option json [String, nil] :template
  def json_render_html(status, json = {})
    unless json[:html]
      if json[:partial]
        json[:html] = render_to_string(partial: json[:partial], locals: json.delete(:locals) || {}, formats: [:html])
      else
        template = json.delete(:template) || action_name
        json[:html] = render_to_string(action: template, layout: false, formats: [:html])
      end
    end
    json_response status, json
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

  private

  def translate_message(message, opts = {})
    raise ArgumentError unless message.is_a? Symbol
    I18n.t(message, opts.reverse_merge(scope: :messages, default: [:default, message])).html_safe
  end

  def referrer_host
    URI.parse(request.referrer).try(:host) if request.referrer
  end

  def request_variant
    @request_variant ||= request.variant || detect_device_format
  end

  def detect_device_format
    case request.user_agent
    when /iPad/i
      request.variant = :tablet
    when /iPhone/i
      request.variant = :phone
    when /Android/i && /mobile/i
      request.variant = :phone
    when /Android/i
      request.variant = :tablet
    when /Windows Phone/i
      request.variant = :phone
    else
      request.variant = :unrecognized
    end
    request.variant
  end
end
