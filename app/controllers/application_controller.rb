class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  # @param [User]
  def login(user)
    session_manager.login(user)
  end

  def leave
    session_manager.logout
  end

  def current_user
    session_manager.current_user
  end

  def session_manager
    @session_manager ||= SessionManager.new(session)
  end
end
