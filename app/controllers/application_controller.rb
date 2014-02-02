class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  # @param code [Integer]
  def error(code)
    render status: code, text: code.inspect
  end

  def current_user
    session_manager.current_user
  end
  helper_method :current_user

  def session_manager
    @session_manager ||= SessionManager.new(session)
  end
end
