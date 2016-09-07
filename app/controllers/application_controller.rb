class ApplicationController < ActionController::Base
  include Concerns::ControllerFramework

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session # or :exception
  skip_before_filter :verify_authenticity_token

  if ___access_config = APP_CONFIG['http_access']
    http_basic_authenticate_with ___access_config.symbolize_keys
  end

  before_action :store_session, :check_if_tos_accepted
  before_action :redirect_to_mobile!, if: -> { mobile_device? && !account_page? && !request.xhr? }

  protected

  def store_session
    Thread.current[:session_id] = session[:session_id]
  end

  def redirect_to_mobile!
    mobile_host = Rails.env.development? ? "#{request.scheme}://#{request.host}:8080" : APP_CONFIG['mobile_site_url']
    redirect_to "#{mobile_host}#{request.fullpath}", status: 301
  end

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

  def account_page?
    request.path == "/account"
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
    json[:html] ||= json_body(json)
    json_response status, json
  end

  def json_body(json)
    if json[:partial]
      render_to_string(partial: json[:partial], locals: json.delete(:locals) || {}, formats: [:html])
    else
      template = json.delete(:template) || action_name
      render_to_string(action: template, layout: false, formats: [:html])
    end
  end

  private

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

  def referrer_host
    URI.parse(request.referrer).try(:host) if request.referrer
  end

  def request_variant
    @request_variant ||= request.variant || detect_device_format
  end

  def check_if_tos_accepted
    @show_tos_popup = !(current_user.tos_accepted? || !TosVersion.active.try(:requires_acceptance?))
  end

  def show_tos_popup?
    @show_tos_popup
  end
  helper_method :show_tos_popup?
end
