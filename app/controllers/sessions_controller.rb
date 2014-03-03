class SessionsController < ApplicationController

  rescue_from AuthenticationError do |e|
    json_fail message: e.message
  end

  # Logins user
  def create
    session_manager.login(params[:email], params[:password])
    json_redirect account_info_path
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end