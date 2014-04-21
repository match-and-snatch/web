class SessionsController < ApplicationController

  rescue_from AuthenticationError do |e|
    json_fail message: e.message
  end

  # Logins user
  def create
    reset_session
    user = session_manager.login(params[:email], params[:password], params[:remember_me])
    # user.profile_disabled? ? json_redirect(account_path) : json_reload
    json_reload
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end