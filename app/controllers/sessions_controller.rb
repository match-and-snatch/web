class SessionsController < ApplicationController

  rescue_from AuthenticationError do |e|
    json_fail message: e.message
  end

  # Logins user
  def create
    reset_session
    user = session_manager.login(params[:email], params[:password])
    user.has_incomplete_profile? ? json_redirect(finish_profile_path) : json_reload
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end