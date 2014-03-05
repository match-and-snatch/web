class SessionsController < ApplicationController

  rescue_from AuthenticationError do |e|
    json_fail message: e.message
  end

  # Logins user
  def create
    user = session_manager.login(params[:email], params[:password])
    user.complete_profile? ? json_reload : json_redirect(finish_profile_path)
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end